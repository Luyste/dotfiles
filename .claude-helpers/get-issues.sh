#!/usr/bin/env bash
# List open issues for the current repo as "#NUM - Title" lines.
# Caches results for 5 minutes per repo for fast tab-completion.
#
# Usage:
#   get-issues.sh [--type TYPE] [--stage STAGE] [--no-cache]
#
# Examples:
#   get-issues.sh --type story --stage backlog   # /implement candidates
#   get-issues.sh --type epic --stage backlog    # /refine candidates
#   get-issues.sh --stage ready-for-review       # /review candidates
#   get-issues.sh --stage needs-changes          # /fix candidates

set -euo pipefail

# shellcheck source=gh-config.sh
source "$(dirname "$0")/gh-config.sh"

TYPE=""
STAGE=""
USE_CACHE=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)     TYPE="$2"; shift 2 ;;
    --stage)    STAGE="$2"; shift 2 ;;
    --no-cache) USE_CACHE=0; shift ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "${REPO:-}" ]]; then
  echo "error: could not determine repo (no project.config.md, gh repo view failed)" >&2
  exit 1
fi

LABEL_ARGS=()
[[ -n "$TYPE"  ]] && LABEL_ARGS+=(--label "type:$TYPE")
[[ -n "$STAGE" ]] && LABEL_ARGS+=(--label "stage:$STAGE")

CACHE_DIR="$HOME/.cache/claude-helpers"
mkdir -p "$CACHE_DIR"
CACHE_KEY="${REPO//\//-}_type-${TYPE:-any}_stage-${STAGE:-any}"
CACHE_FILE="$CACHE_DIR/issues_${CACHE_KEY}"
CACHE_TTL=300

if (( USE_CACHE )) && [[ -f "$CACHE_FILE" ]]; then
  age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE") ))
  if (( age < CACHE_TTL )); then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

gh issue list \
  --repo "$REPO" \
  --state open \
  "${LABEL_ARGS[@]}" \
  --limit 200 \
  --json number,title \
  --jq '.[] | "#\(.number) - \(.title)"' \
  | tee "$CACHE_FILE"
