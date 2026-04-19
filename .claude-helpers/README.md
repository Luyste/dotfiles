# ~/.claude-helpers

Global scripts backing the `/idea`, `/refine`, `/implement`, `/review`, `/fix`, `/board` workflow.
Shared by **all** projects that have a `.claude/project.config.md` (set up via `/setup`).

## Scripts

| Script | Purpose |
|---|---|
| `gh-config.sh` | `source` this to load `OWNER`/`REPO`/`PROJECT_NUMBER`/`STATUS_*` env from the nearest `.claude/project.config.md`. Falls back to `gh repo view` for the repo. |
| `labels.sh` | Shared taxonomy (`TYPE_LABELS` / `STAGE_LABELS` arrays). |
| `labels-bootstrap.sh` | Create the standardized `type:*`, `stage:*`, `area:*` labels in a repo. Idempotent. |
| `get-issues.sh` | List open issues as `#NUM - Title`. `--type`, `--stage` filters. 5-min per-repo cache. |
| `select-issue.sh` | Pipe `get-issues.sh` through `fzf`. Prints just the number. |
| `issue-create.sh` | Create an issue with `type:*` + `stage:backlog` + `area:*` labels, add to board, set Status = Backlog. |
| `issue-set-stage.sh` | Swap the `stage:*` label AND update the project board Status field (keeps them in sync). |
| `issue-link-parent.sh` | Link a child issue as a sub-issue of a parent epic. |
| `claude-menu.sh` | Interactive TUI menu (requires `gum`). |

## Label taxonomy

Three orthogonal dimensions — a single issue carries one from each:

- **Type**: `type:epic`, `type:story`, `type:bug`, `type:chore`
- **Stage**: `stage:backlog`, `stage:refined`, `stage:in-progress`, `stage:ready-for-review`, `stage:needs-changes`, `stage:ready-to-merge`, `stage:blocked`
- **Area**: `area:<name>` (per-project, set during `/setup`)

Stage labels mirror board Status columns. Tab-completion uses labels (fast, no GraphQL); the kanban board uses Status.

## Shell setup (zsh)

Install dependencies:
```bash
brew install fzf jq gum
```

Add to `~/.zshrc`:
```bash
# Tab-completion for claude-story aliases
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit

# Aliases — fuzzy-pick an issue, feed it to claude
alias ci='claude "/implement $(~/.claude-helpers/select-issue.sh --type story --stage backlog)"'
alias cr='claude "/refine $(~/.claude-helpers/select-issue.sh --type epic --stage backlog)"'
alias cv='claude "/review $(~/.claude-helpers/select-issue.sh --stage ready-for-review)"'
alias cf='claude "/fix $(~/.claude-helpers/select-issue.sh --stage needs-changes)"'
alias cid='claude /idea'
alias cm='~/.claude-helpers/claude-menu.sh'
```

Reload: `source ~/.zshrc`.

## Usage

**Tab-complete:**
```
ci <TAB>
# Shows open stories ready to implement, with titles. Pick one, Enter.
```

**fzf-pick:**
```
ci
# Opens fzf with filtered issues. Type to search, Enter to run.
```

**Menu:**
```
cm
# Full TUI: pick action → pick issue → confirm → run.
```

## How it auto-detects the repo

`gh-config.sh` walks up from `$PWD` looking for `.claude/project.config.md`. Found → uses its owner/repo/project IDs. Not found → falls back to `gh repo view` (enough for read-only listing). This means the same aliases work across all your projects without re-exporting env vars.

Issue-list caches are namespaced per `owner-repo` so switching repos never shows stale results from another repo.
