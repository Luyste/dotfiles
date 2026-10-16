#!/bin/bash
# A small switchyard for Zed: agents (pi, claude) run in tmux sessions, and
# Zed tasks (tasks.json) attach to them, send code to them and fork them.
#
#   agent.sh attach <dir> [agent]   attach to the agent in <dir>, or start one (default: pi)
#   agent.sh send <dir>             paste the selection as context, finish the prompt in the agent
#   agent.sh fork <dir>             fork the agent in <dir> into a new worktree, open it in Zed
#
# send reads the selection from $SY_FILE, $SY_ROW and $SY_TEXT (set by the task).
set -u

die() {
	osascript -e "display notification \"$1\" with title \"agent\"" >/dev/null 2>&1
	echo "agent: $1" >&2
	exit 1
}

# "<pid> <agent>" of the first pi/claude process at or below pid $1
find_agent() {
	local first second _
	read -r first second _ <<<"$(ps -o command= -p "$1")"
	first=${first##*/} second=${second##*/}
	case $first in
	pi | claude) echo "$1 $first" && return ;;
	node | bun | deno | python*) case $second in pi | claude) echo "$1 $second" && return ;; esac ;;
	esac
	local child
	for child in $(pgrep -P "$1"); do
		find_agent "$child" && return
	done
	return 1
}

# "<pane> <session> <pid> <agent>" of the agent running in folder $1
agent_in() {
	local pane session pid path found
	while read -r pane session pid path; do
		[ "$path" = "$1" ] || continue
		found=$(find_agent "$pid") && echo "$pane $session $found" && return
	done < <(tmux list-panes -a -F '#{pane_id} #{session_name} #{pane_pid} #{pane_current_path}' 2>/dev/null)
	return 1
}

# Start a command in a new background session in folder $1, named after the
# agent and the folder like switchyard does: "<agent>-<branch>". Prints the name.
start() {
	local dir=$1 agent=$2
	shift
	local folder=${dir##*/}
	local base name n=1
	base=$(echo "$agent-${folder#*.}" | tr '.: ' '___' | cut -c1-32)
	name=$base
	while tmux has-session -t "=$name" 2>/dev/null; do
		n=$((n + 1)) name=$base-$n
	done
	# Through a login shell for your PATH; a shell stays when the agent exits
	tmux new-session -d -s "$name" -c "$dir" "$SHELL" -l -i -c "$(printf '%q ' "$@"); exec $SHELL" || exit 1
	echo "$name"
}

# Paste $2 into pane $1 as typed text (bracketed: newlines don't submit)
paste() {
	printf '%s' "$2" | tmux load-buffer -b agent - && tmux paste-buffer -p -d -b agent -t "$1"
}

ask() { # a line of text from a dialog; empty on cancel
	osascript -e "text returned of (display dialog \"$1\" default answer \"\")" 2>/dev/null
}

context() {
	[ -n "${SY_TEXT:-}" ] || return 0
	printf 'From %s:%s:\n```\n%s\n```\n' "$SY_FILE" "$SY_ROW" "$SY_TEXT"
}

cmd=${1:-}
dir=$(cd "${2:-.}" && pwd -P) || die "no folder ${2:-}"

case $cmd in
attach)
	if found=$(agent_in "$dir"); then
		read -r _ session _ <<<"$found"
	else
		session=$(start "$dir" "${3:-pi}")
	fi
	exec tmux attach-session -t "=$session"
	;;

send)
	found=$(agent_in "$dir") || die "no agent running in ${dir##*/}"
	read -r pane _ <<<"$found"
	paste "$pane" "$(context)"
	;;

fork)
	found=$(agent_in "$dir") || die "no agent running in ${dir##*/}"
	read -r _ _ pid agent <<<"$found"
	branch=$(ask "Fork the $agent session into a new worktree. Branch:")
	[ -n "$branch" ] || exit 0

	if command -v wt >/dev/null; then
		# wt brings its path template and hooks; the JSON result is the last "{" line
		path=$(cd "$dir" && command wt switch --create "$branch" --no-cd --yes --format json | grep '^{' | tail -1 | jq -r .path)
	else
		main=$(git -C "$dir" worktree list --porcelain | head -1 | cut -d' ' -f2-)
		path=$main.${branch//\//-}
		git -C "$dir" worktree add -b "$branch" "$path" >&2
	fi
	[ -d "${path:-}" ] || die "couldn't create a worktree for $branch"

	note="Note: this session was forked from $dir and now runs in $path. Absolute paths in the history refer to the original worktree; work in the new one."
	if [ "$agent" = claude ]; then
		id=$(jq -r .sessionId ~/.claude/sessions/"$pid".json 2>/dev/null)
		[ -n "$id" ] && [ "$id" != null ] || die "no session id for claude ($pid)"
		start "$path" claude --resume "$id" --fork-session "$note" >/dev/null
	else
		# pi: the folder's newest session file is the live one
		sessions=~/.pi/agent/sessions/--$(echo "${dir#/}" | tr '/:' '--')--
		file=$(ls -t "$sessions"/*.jsonl 2>/dev/null | head -1)
		[ -n "$file" ] || die "no pi session found in $sessions"
		start "$path" pi --fork "$file" "$note" >/dev/null
	fi
	zed "$path"
	;;

*)
	sed -n '2,10p' "$0" | cut -c3-
	exit 1
	;;
esac
