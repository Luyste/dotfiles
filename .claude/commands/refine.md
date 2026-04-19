# Refine — Epic to Implementation-Ready Stories

Take a raw epic from Backlog, discuss scope with the user, break it into user stories as sub-issues, and write an implementation plan for each story.

**REQUIRED:** Read `.claude/project.config.md` first to get repo, project, and status settings. If the file doesn't exist, tell the user to run `/setup` first.

The user's input is: $ARGUMENTS

**REQUIRED BACKGROUND:** Use questioning techniques from `superpowers:brainstorming` — one question at a time, multiple choice preferred, propose 2-3 approaches with trade-offs and your recommendation. YAGNI ruthlessly.

**REQUIRED:** Use `superpowers:writing-plans` to create the implementation plan for each story.

## Issue Hierarchy

```
Epic (parent issue, from /idea)
├── User Story (sub-issue, created during /refine)
│   └── Tasks as checkboxes in the story body (plan phases)
├── User Story (sub-issue)
│   └── Tasks as checkboxes
└── ...
```

## Usage

- `/refine` — shows backlog items to pick from
- `/refine 25` — refine issue #25 directly

## Flow

```dot
digraph refine_flow {
  "Read project.config.md" -> "Show backlog items (or use specified #)";
  "Show backlog items (or use specified #)" -> "User picks one";
  "User picks one" -> "Read epic + explore codebase";
  "Read epic + explore codebase" -> "Ask clarifying questions (one at a time)";
  "Ask clarifying questions (one at a time)" -> "Aligned on scope?";
  "Aligned on scope?" -> "Ask clarifying questions (one at a time)" [label="no"];
  "Aligned on scope?" -> "Propose 2-3 approaches" [label="yes"];
  "Propose 2-3 approaches" -> "Break into user stories";
  "Break into user stories" -> "User approves stories?";
  "User approves stories?" -> "Break into user stories" [label="adjust"];
  "User approves stories?" -> "Write implementation plan per story" [label="yes"];
  "Write implementation plan per story" -> "User approves plans?";
  "User approves plans?" -> "Write implementation plan per story" [label="adjust"];
  "User approves plans?" -> "Create sub-issues + update board" [label="yes"];
  "Create sub-issues + update board" -> "Move epic to Refined";
  "Move epic to Refined" -> "Confirm to user";
}
```

## Process

### 1. Select & Understand
- Read `.claude/project.config.md` for all project settings
- If `$ARGUMENTS` contains an issue number, use it directly
- Otherwise, run `~/.claude-helpers/get-issues.sh --type epic --stage backlog`, then present the candidates using the `AskUserQuestion` tool. Proceed with the picked number
- Fetch the current issue body
- Explore relevant parts of the codebase to understand current state

### 2. Discuss (brainstorming techniques)
- Ask clarifying questions **one at a time**
- Prefer **multiple choice** questions when possible
- Focus on: purpose, constraints, success criteria, edge cases
- Once scope is clear, **propose 2-3 approaches** with trade-offs and your recommendation

### 3. Break into User Stories
Split the epic into user stories. Each story should be:
- Small enough for a single implementation session
- Independent enough for a worker agent to execute without context from other stories
- In the format:
  ```
  As a [user type], I want [goal] so that [benefit]

  ## Acceptance Criteria
  - [ ] ...
  - [ ] ...
  ```
Show the proposed stories, adjust until user approves.

### 4. Write Implementation Plans
For each story, invoke `superpowers:writing-plans` to create a detailed plan. The plan should:
- Reference the story's acceptance criteria
- Break work into ordered phases as task checkboxes
- Include relevant file paths, patterns to follow, and technical decisions
- Be self-contained enough for a worker agent to execute without additional discussion

### 5. Create Sub-Issues & Update Board
Once user approves the plans, for each story:

1. Write the story body to a temp file (user story + acceptance criteria + implementation plan with task checkboxes).
2. Create the story + add to board + set Backlog status, all at once:
   ```bash
   ~/.claude-helpers/issue-create.sh \
     --type story \
     --area "<area>" \
     --title "<story title>" \
     --body-file "<tmpfile>" \
     --stage backlog
   ```
3. Extract the issue number from the URL the helper prints, then link as a sub-issue of the epic:
   ```bash
   ~/.claude-helpers/issue-link-parent.sh <child-number> <epic-number>
   ```

Then move the epic to Refined:
```bash
~/.claude-helpers/issue-set-stage.sh <epic-number> refined
```

The helpers keep the `stage:*` label and board Status column in sync automatically.

## Important

- The refinement conversation is the core value — don't rush it
- Each story must be self-contained with its full implementation plan
- A worker agent should be able to pick up any story and start implementing from the checkboxes alone
- Add all sub-issues to the project board in Backlog status
