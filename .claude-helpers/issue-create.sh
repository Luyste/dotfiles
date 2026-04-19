#!/usr/bin/env bash
# Create an issue with standardized labels, add it to the project, set Backlog status.
#
# Usage:
#   issue-create.sh --type TYPE --area AREA --title TITLE [--body-file FILE] [--stage STAGE]
#
# Defaults:
#   --stage backlog
#
# Prints the issue URL on success.

set -euo pipefail

# shellcheck source=gh-config.sh
source "$(dirname "$0")/gh-config.sh"

TYPE=""
AREA=""
TITLE=""
BODY_FILE=""
STAGE="backlog"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)      TYPE="$2"; shift 2 ;;
    --area)      AREA="$2"; shift 2 ;;
    --title)     TITLE="$2"; shift 2 ;;
    --body-file) BODY_FILE="$2"; shift 2 ;;
    --stage)     STAGE="$2"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$TYPE" || -z "$TITLE" ]]; then
  echo "usage: issue-create.sh --type TYPE --area AREA --title TITLE [--body-file FILE] [--stage STAGE]" >&2
  exit 2
fi

if [[ -z "${REPO:-}" || -z "${PROJECT_NUMBER:-}" ]]; then
  echo "error: missing repo or project config — run /setup first" >&2
  exit 1
fi

CREATE_ARGS=(--repo "$REPO" --title "$TITLE"
             --label "type:$TYPE" --label "stage:$STAGE")
[[ -n "$AREA"      ]] && CREATE_ARGS+=(--label "area:$AREA")
[[ -n "$BODY_FILE" ]] && CREATE_ARGS+=(--body-file "$BODY_FILE")
[[ -z "$BODY_FILE" ]] && CREATE_ARGS+=(--body "")

ISSUE_URL="$(gh issue create "${CREATE_ARGS[@]}")"
echo "$ISSUE_URL"

# Add to project board. Prints item ID we can stash for subsequent status updates.
ITEM_ID="$(gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$ISSUE_URL" --format json --jq .id)"

# Set board status to Backlog if we have the IDs
if [[ -n "${PROJECT_ID:-}" && -n "${STATUS_FIELD_ID:-}" && -n "${STATUS_BACKLOG:-}" ]]; then
  gh api graphql -f query='
    mutation($project: ID!, $item: ID!, $field: ID!, $option: String!) {
      updateProjectV2ItemFieldValue(input: {
        projectId: $project, itemId: $item, fieldId: $field,
        value: { singleSelectOptionId: $option }
      }) { projectV2Item { id } }
    }' \
    -f project="$PROJECT_ID" \
    -f item="$ITEM_ID" \
    -f field="$STATUS_FIELD_ID" \
    -f option="$STATUS_BACKLOG" >/dev/null
fi

# Invalidate list caches for this repo so the new issue shows up immediately
rm -f "$HOME/.cache/claude-helpers/issues_${REPO//\//-}"_* 2>/dev/null || true
