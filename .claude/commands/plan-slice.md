# Plan a safe implementation slice

Task:

$ARGUMENTS

Use this workflow for planning:

- Use Opus 4.8 High as the orchestrator/planner when available.
- Use Haiku 4.5 High as a read-only code reader when useful.
- Do not implement during this command.
- Inspect relevant files before proposing changes.
- Find the smallest safe implementation slice.
- Preserve current product behavior unless the task explicitly says otherwise.
- Prevent scope creep.

Use subagents when useful:
- `haiku-code-reader` for fast file discovery, reference tracing, and existing-behavior summaries.
- `opus-planner` for architecture, risk, sequencing, and acceptance criteria.

Output:

## Implementation Plan

### Goal

### Relevant files inspected

### Current behavior

### Proposed slice

### Files likely affected

### Risks

### Acceptance criteria

### Verification commands

### Approval needed

Stop and wait for approval before implementation.