# Idea — Quick Capture to Backlog

Capture a raw feature idea as a GitHub Issue (epic) and add it to the project board in Backlog.

**REQUIRED:** Read `.claude/project.config.md` first to get repo, project, and label settings. If the file doesn't exist, tell the user to run `/setup` first.

The user's input is: $ARGUMENTS

## Usage

`/idea <area> - <description>`

- **area**: One of the area labels from project config
- **description**: The idea in the user's own words

## Flow

1. Read `.claude/project.config.md` for repo owner, repo name, project number, area labels, and status IDs
2. Parse the area and description from the user's input
3. Validate the area matches one of the configured area labels
4. Ask the user: **"Want me to ask clarifying questions, or just dump it?"**
5. If clarify: ask focused questions, then proceed
6. If dump: proceed immediately
7. Create a GitHub Issue:
   - Title: short summary of the idea
   - Body: the user's description (and any clarifications)
   - Labels: the area label
8. Add the issue to the project board in **Backlog** status
9. Confirm with issue link

## Issue Hierarchy

```
Epic (parent issue, created by /idea)
├── User Story (sub-issue, created during /refine)
│   └── Tasks as checkboxes in the story body
├── User Story (sub-issue)
│   └── Tasks as checkboxes
└── ...
```

## Commands

Read owner, repo, project number, project ID, field ID, and status option IDs from `.claude/project.config.md`.

**Create issue:**
```bash
gh issue create --repo <owner>/<repo> --title "<title>" --body "<body>" --label "<Area>"
```

**Add to project:**
```bash
gh project item-add <project-number> --owner <owner> --url <issue-url>
```

**Set status to Backlog:**
Use GraphQL mutation `updateProjectV2ItemFieldValue` with project ID, field ID, and Backlog option ID from config.

## Important

- Do NOT refine the idea into user story format — keep it raw
- Do NOT create sub-issues — that happens during `/refine`
- Keep the issue body close to the user's original wording
