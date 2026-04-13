# Fix — Address Review Feedback

Pick up a story from Needs Changes, read the review feedback, fix the issues in the epic's worktree, and resubmit for review.

**REQUIRED:** Read `.claude/project.config.md` first to get repo, project, build, and status settings. If the file doesn't exist, tell the user to run `/setup` first.

The user's input is: $ARGUMENTS

## Usage

- `/fix` — shows stories that need changes
- `/fix 31` — fix issue #31 directly

## Flow

```dot
digraph fix_flow {
  "Read project.config.md" -> "Show Needs Changes stories (or use specified #)";
  "Show Needs Changes stories (or use specified #)" -> "User picks one";
  "User picks one" -> "Read story + review comments";
  "Read story + review comments" -> "Find epic worktree";
  "Find epic worktree" -> "Categorize issues (Critical → Important → Minor)";
  "Categorize issues (Critical → Important → Minor)" -> "Move to In Progress";
  "Move to In Progress" -> "Fix issues in priority order";
  "Fix issues in priority order" -> "All issues addressed?";
  "All issues addressed?" -> "Fix issues in priority order" [label="no"];
  "All issues addressed?" -> "Move to Ready for Review" [label="yes"];
  "Move to Ready for Review" -> "Post summary comment + confirm to user";
}
```

## Process

### 1. Select Story
- Read `.claude/project.config.md` for all project settings
- If no issue number provided, fetch all project items with status "Needs Changes"
- Show them to the user, let them pick
- Fetch the full issue body and all comments (review feedback is in comments)

### 2. Read Review Feedback
- Parse the review comment for issues by severity:
  - **Critical (Must Fix)** — address first
  - **Important (Should Fix)** — address second
  - **Minor (Nice to Have)** — address if reasonable
- Present the issues to the user for confirmation before starting

### 3. Find the Worktree
- Identify the parent epic number
- Find the epic's worktree (it should still exist from implementation):
  ```bash
  git worktree list | grep "feat/<epic-number>"
  ```
- `cd` into the worktree

### 4. Fix Issues
- Move story to **In Progress** on the board
- Wait for explicit go-ahead from the user
- Work through issues in priority order: Critical → Important → Minor
- Follow the reviewer's "How to fix" suggestions where provided
- After fixing, run lint + typecheck from config to verify nothing is broken

### 5. Resubmit
- Post a comment on the issue summarizing what was fixed:
  ```markdown
  ## Fixes Applied
  
  - [x] Critical: <what was fixed>
  - [x] Important: <what was fixed>
  - [x] Minor: <what was fixed / skipped with reason>
  ```
- Move story back to **Ready for Review** on the board

## Commands

Read all IDs from `.claude/project.config.md`.

**Read story + comments:**
```bash
gh issue view <number> --repo <owner>/<repo> --comments
```

**Post fix summary:**
```bash
gh issue comment <number> --repo <owner>/<repo> --body "<summary>"
```

**Set status to In Progress / Ready for Review:**
Use GraphQL mutation `updateProjectV2ItemFieldValue` with project ID, field ID, and option IDs from config.

## Important

- Always read ALL review comments — there may be multiple rounds of feedback
- Fix Critical issues first, never skip them
- Post a summary comment so the reviewer knows what changed
- Run lint + typecheck before resubmitting
- The worktree should already exist — if it doesn't, something went wrong
