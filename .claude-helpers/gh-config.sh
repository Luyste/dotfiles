#!/usr/bin/env bash
# Source this file to load project configuration into env vars.
#
# Exports (when available):
#   REPO              owner/repo (from project.config.md, or autodetected via gh)
#   OWNER             owner
#   REPO_NAME         repo name (without owner)
#   PROJECT_NUMBER    GitHub Project v2 number
#   PROJECT_ID        GitHub Project v2 node ID
#   STATUS_FIELD_ID   Status field node ID
#   STATUS_BACKLOG, STATUS_REFINED, STATUS_IN_PROGRESS,
#   STATUS_READY_FOR_REVIEW, STATUS_NEEDS_CHANGES,
#   STATUS_READY_TO_MERGE, STATUS_DONE   option IDs (when set)
#   BUILD_INSTALL, BUILD_LINT, BUILD_TYPECHECK, BUILD_TEST
#   AREA_LABELS       comma-separated list
#   CONFIG_PATH       resolved path to project.config.md (empty if none)
#
# Walks up from $PWD to find .claude/project.config.md. Falls back to
# `gh repo view` for REPO/OWNER/REPO_NAME when no config file exists, so
# helpers that only need the repo still work.

_gh_config_find() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.claude/project.config.md" ]]; then
      echo "$dir/.claude/project.config.md"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

_gh_config_get() {
  # $1: key (e.g. "owner", "number", "Backlog")
  # Reads "- <key>: <value>" from $CONFIG_PATH
  [[ -z "$CONFIG_PATH" ]] && return 1
  awk -v key="$1" '
    $0 ~ "^- "key":" {
      sub("^- "key": *", "")
      print
      exit
    }
  ' "$CONFIG_PATH"
}

CONFIG_PATH="$(_gh_config_find || true)"

if [[ -n "$CONFIG_PATH" ]]; then
  OWNER="$(_gh_config_get owner)"
  REPO_NAME="$(_gh_config_get repo)"
  REPO="${OWNER}/${REPO_NAME}"

  PROJECT_NUMBER="$(_gh_config_get number)"
  PROJECT_ID="$(_gh_config_get id)"
  STATUS_FIELD_ID="$(_gh_config_get field-id)"

  STATUS_BACKLOG="$(_gh_config_get Backlog)"
  STATUS_REFINED="$(_gh_config_get Refined)"
  STATUS_IN_PROGRESS="$(_gh_config_get 'In Progress')"
  STATUS_READY_FOR_REVIEW="$(_gh_config_get 'Ready for Review')"
  STATUS_NEEDS_CHANGES="$(_gh_config_get 'Needs Changes')"
  STATUS_READY_TO_MERGE="$(_gh_config_get 'Ready to Merge')"
  STATUS_DONE="$(_gh_config_get Done)"

  BUILD_INSTALL="$(_gh_config_get install)"
  BUILD_LINT="$(_gh_config_get lint)"
  BUILD_TYPECHECK="$(_gh_config_get typecheck)"
  BUILD_TEST="$(_gh_config_get test)"

  AREA_LABELS="$(_gh_config_get areas)"
else
  # Fallback: enough for read-only issue listing
  if command -v gh >/dev/null 2>&1; then
    REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
    if [[ -n "$REPO" ]]; then
      OWNER="${REPO%%/*}"
      REPO_NAME="${REPO##*/}"
    fi
  fi
fi

export CONFIG_PATH REPO OWNER REPO_NAME
export PROJECT_NUMBER PROJECT_ID STATUS_FIELD_ID
export STATUS_BACKLOG STATUS_REFINED STATUS_IN_PROGRESS
export STATUS_READY_FOR_REVIEW STATUS_NEEDS_CHANGES
export STATUS_READY_TO_MERGE STATUS_DONE
export BUILD_INSTALL BUILD_LINT BUILD_TYPECHECK BUILD_TEST
export AREA_LABELS
