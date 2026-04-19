#!/usr/bin/env bash
# Pick an issue via fzf. Prints just the issue number.
# Forwards all args to get-issues.sh for filtering.
#
# Examples:
#   select-issue.sh --type story --stage backlog
#   select-issue.sh --stage ready-for-review

set -euo pipefail

HELPERS="$(dirname "$0")"

"$HELPERS/get-issues.sh" "$@" \
  | fzf --height 40% --border --prompt "Select issue: " \
  | sed -n 's/^#\([0-9][0-9]*\).*/\1/p'
