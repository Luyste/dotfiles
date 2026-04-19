# Board — View Kanban State

Show the current state of the project board.

**REQUIRED:** Read `.claude/project.config.md` first to get repo, project, and label settings. If the file doesn't exist, tell the user to run `/setup` first.

The user's input is: $ARGUMENTS

## Usage

- `/board` — full board overview
- `/board Portal` — filter by area
- `/board refined` — filter by status

## Flow

1. Read `.claude/project.config.md` for project number, owner, and area labels
2. Fetch all project items with status and labels
3. Group by status column
4. If area filter provided, only show matching items
5. Display as a clean summary

## Commands

- **Fetch items for one stage**: `~/.claude-helpers/get-issues.sh --stage <stage>` (prints `#NUM - Title`)
- **Fetch all board items with full metadata** (when you need area labels or sub-issue counts):
  ```bash
  gh project item-list <project-number> --owner <owner> --format json
  ```
- **Get issue details**: `gh issue view <number> --repo <repo> --json labels,title,number,parent`

## Display Format

```
## <Project Title>

### Backlog (3)
- #30 [Area1] Some idea title
- #31 [Area2] Another idea
- #32 [Area3] Third idea

### Refined (1)
- #25 [Area1] Refined story (3 sub-issues)

### In Progress (1)
- #26 [Area2] Story being worked on

### Ready for Review (0)

### Done (2)
- #24 [Area1] Completed story
- #27 [Area2] Another completed story
```

Show sub-issue progress where available. Omit empty columns except Ready for Review (useful to see it's empty). Keep it scannable.
