# Idea — Quick Capture to Backlog

Capture a raw feature idea as a GitHub epic and drop it into the project board at Backlog.

**REQUIRED:** `.claude/project.config.md` must exist. If not, tell the user to run `/setup` first.

The user's input is: $ARGUMENTS

## Usage

`/idea <area> - <description>`

- **area**: one of the `area:*` labels configured in `project.config.md`
- **description**: the idea in the user's own words

## Flow

1. Parse `area` and `description` from `$ARGUMENTS`.
2. Validate `area` matches one of the areas in `project.config.md`. If not, list valid areas and stop.
3. Ask: **"Want me to ask clarifying questions, or just dump it?"**
   - If clarify: ask focused questions (one at a time), then proceed.
   - If dump: proceed immediately.
4. Draft a short issue title from the description.
5. Write the body to a temp file (`mktemp`) so it survives shell escaping.
6. Create the epic via helper:
   ```bash
   ~/.claude-helpers/issue-create.sh \
     --type epic \
     --area "<area>" \
     --title "<title>" \
     --body-file "<tmpfile>" \
     --stage backlog
   ```
   This creates the issue with labels `type:epic`, `stage:backlog`, `area:<area>`, adds it to the project board, and sets Status = Backlog.
7. Report the issue URL to the user.

## Issue Hierarchy

```
Epic (created here by /idea)       ← type:epic, stage:backlog
├── Story (created by /refine)     ← type:story, stage:backlog
│   └── Tasks as checkboxes in the body
└── Story
```

## Important

- **Do NOT refine** the idea into user-story format — keep the body close to the user's wording.
- **Do NOT create sub-issues** — that happens in `/refine`.
- The helper handles repo/project/status resolution — don't hand-craft `gh` or GraphQL calls.
