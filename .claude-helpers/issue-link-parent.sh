#!/usr/bin/env bash
# Link an issue as a sub-issue of a parent (GitHub sub-issues API).
#
# Usage:
#   issue-link-parent.sh <child-number> <parent-number>

set -euo pipefail

# shellcheck source=gh-config.sh
source "$(dirname "$0")/gh-config.sh"

CHILD="${1:-}"
PARENT="${2:-}"

if [[ -z "$CHILD" || -z "$PARENT" ]]; then
  echo "usage: issue-link-parent.sh <child-number> <parent-number>" >&2
  exit 2
fi

CHILD_NODE_ID="$(gh api "/repos/$REPO/issues/$CHILD" --jq '.node_id')"
gh api --method POST "/repos/$REPO/issues/$PARENT/sub_issues" \
  -f sub_issue_id="$CHILD_NODE_ID" >/dev/null

echo "Linked #$CHILD as sub-issue of #$PARENT"
