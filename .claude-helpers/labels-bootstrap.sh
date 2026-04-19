#!/usr/bin/env bash
# Create the standardized type:/stage: labels in the current repo.
# Idempotent — existing labels are skipped (not overwritten).
#
# Usage:
#   labels-bootstrap.sh [--areas "Area1,Area2,..."]
#
# Area labels use color bbbbbb by default; customize in GitHub UI if you want.

set -euo pipefail

HELPERS="$(dirname "$0")"
# shellcheck source=gh-config.sh
source "$HELPERS/gh-config.sh"
# shellcheck source=labels.sh
source "$HELPERS/labels.sh"

AREAS=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --areas) AREAS="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "${REPO:-}" ]]; then
  echo "error: could not determine repo" >&2
  exit 1
fi

create_label() {
  local name="$1" color="$2" desc="$3"
  if gh label list --repo "$REPO" --json name --jq '.[].name' | grep -qx "$name"; then
    echo "  = $name (exists)"
  else
    gh label create "$name" --repo "$REPO" --color "$color" --description "$desc" >/dev/null
    echo "  + $name"
  fi
}

echo "Bootstrapping labels in $REPO"

echo "Types:"
for entry in "${TYPE_LABELS[@]}"; do
  IFS='|' read -r name color desc <<< "$entry"
  create_label "$name" "$color" "$desc"
done

echo "Stages:"
for entry in "${STAGE_LABELS[@]}"; do
  IFS='|' read -r name color desc <<< "$entry"
  create_label "$name" "$color" "$desc"
done

if [[ -n "$AREAS" ]]; then
  echo "Areas:"
  IFS=',' read -ra AREA_ARR <<< "$AREAS"
  for area in "${AREA_ARR[@]}"; do
    area="$(echo "$area" | xargs)" # trim
    [[ -z "$area" ]] && continue
    create_label "area:$area" "bbbbbb" "Area: $area"
  done
fi

echo "Done."
