#!/usr/bin/env bash
# Move an issue to a new stage. Updates both the stage:* label AND the
# project board Status field so the two surfaces stay in sync.
#
# Usage:
#   issue-set-stage.sh <issue-number> <stage>
#
# Valid stages: backlog, refined, in-progress, ready-for-review,
#               needs-changes, ready-to-merge, blocked

set -euo pipefail

# shellcheck source=gh-config.sh
source "$(dirname "$0")/gh-config.sh"

ISSUE_NUMBER="${1:-}"
STAGE="${2:-}"

if [[ -z "$ISSUE_NUMBER" || -z "$STAGE" ]]; then
  echo "usage: issue-set-stage.sh <issue-number> <stage>" >&2
  exit 2
fi

if [[ -z "${REPO:-}" ]]; then
  echo "error: could not determine repo" >&2
  exit 1
fi

# 1. Swap the stage:* label on the issue
CURRENT_STAGES="$(gh issue view "$ISSUE_NUMBER" --repo "$REPO" --json labels \
  --jq '.labels[].name | select(startswith("stage:"))' || true)"

while IFS= read -r old; do
  [[ -z "$old" ]] && continue
  [[ "$old" == "stage:$STAGE" ]] && continue
  gh issue edit "$ISSUE_NUMBER" --repo "$REPO" --remove-label "$old" >/dev/null
done <<< "$CURRENT_STAGES"

gh issue edit "$ISSUE_NUMBER" --repo "$REPO" --add-label "stage:$STAGE" >/dev/null

# 2. Update board Status field (if project config is available)
if [[ -n "${PROJECT_ID:-}" && -n "${STATUS_FIELD_ID:-}" ]]; then
  # Resolve stage → status option ID
  case "$STAGE" in
    backlog)          OPTION_ID="${STATUS_BACKLOG:-}" ;;
    refined)          OPTION_ID="${STATUS_REFINED:-}" ;;
    in-progress)      OPTION_ID="${STATUS_IN_PROGRESS:-}" ;;
    ready-for-review) OPTION_ID="${STATUS_READY_FOR_REVIEW:-}" ;;
    needs-changes)    OPTION_ID="${STATUS_NEEDS_CHANGES:-}" ;;
    ready-to-merge)   OPTION_ID="${STATUS_READY_TO_MERGE:-}" ;;
    blocked)          OPTION_ID="" ;; # no matching column by default
    *) echo "unknown stage: $STAGE" >&2; exit 2 ;;
  esac

  if [[ -n "$OPTION_ID" ]]; then
    # Look up the item ID for this issue on the project board
    ITEM_ID="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --format json \
      --jq ".items[] | select(.content.number == $ISSUE_NUMBER) | .id" | head -n1)"

    if [[ -n "$ITEM_ID" ]]; then
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
        -f option="$OPTION_ID" >/dev/null
    fi
  fi
fi

# Invalidate caches
rm -f "$HOME/.cache/claude-helpers/issues_${REPO//\//-}"_* 2>/dev/null || true

echo "Issue #$ISSUE_NUMBER → stage:$STAGE"
