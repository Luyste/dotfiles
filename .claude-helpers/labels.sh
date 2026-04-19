#!/usr/bin/env bash
# Shared label taxonomy for all projects using the /idea-/refine-/implement workflow.
# Source this file to get the TYPE_LABELS / STAGE_LABELS arrays.

# Format: "name|color|description"
# Colors picked to be visually distinct in GitHub's UI.
TYPE_LABELS=(
  "type:epic|5319e7|Parent container for related stories"
  "type:story|1d76db|Implementation-ready unit of work"
  "type:bug|d73a4a|Defect against shipped work"
  "type:chore|c5def5|Maintenance, infra, deps (no user-facing change)"
)

STAGE_LABELS=(
  "stage:backlog|ededed|Captured, not yet refined"
  "stage:refined|0e8a16|Refined into stories (epics)"
  "stage:in-progress|fbca04|Actively being worked"
  "stage:ready-for-review|a2eeef|PR open, awaiting review"
  "stage:needs-changes|e99695|Review feedback to address"
  "stage:ready-to-merge|6f42c1|Approved, awaiting merge"
  "stage:blocked|b60205|Waiting on external input"
)
