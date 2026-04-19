#!/usr/bin/env bash
# Interactive TUI menu: pick an action, pick an issue, run it through Claude.
# Requires: gum, fzf, gh
set -euo pipefail

HELPERS="$(dirname "$0")"

ACTION=$(gum choose \
  "💡 /idea      - Create new epic" \
  "✨ /refine    - Refine an epic into stories" \
  "🔨 /implement - Implement a story" \
  "👀 /review    - Review a story ready for review" \
  "🔧 /fix       - Address review feedback" \
  "📋 /board     - Show kanban state")

run_with_issue() {
  local cmd="$1" type_filter="$2" stage_filter="$3"
  local args=()
  [[ -n "$type_filter"  ]] && args+=(--type  "$type_filter")
  [[ -n "$stage_filter" ]] && args+=(--stage "$stage_filter")

  local num
  num="$("$HELPERS/select-issue.sh" "${args[@]}")"
  [[ -z "$num" ]] && { gum style --foreground 196 "No issue selected"; exit 1; }
  gum confirm "$cmd issue #$num?" && claude "$cmd $num"
}

case $ACTION in
  *"/idea"*)
    IDEA=$(gum input --placeholder "Describe your idea (format: <area> - <description>)...")
    [[ -n "$IDEA" ]] && claude "/idea $IDEA"
    ;;
  *"/refine"*)    run_with_issue /refine    epic  backlog ;;
  *"/implement"*) run_with_issue /implement story backlog ;;
  *"/review"*)    run_with_issue /review    ""    ready-for-review ;;
  *"/fix"*)       run_with_issue /fix       ""    needs-changes ;;
  *"/board"*)     claude "/board" ;;
esac
