# Implement an approved slice

Approved task:

$ARGUMENTS

Use this workflow:

- Use Opus 4.8. High as the orchestrator when available.
- Use Sonnet 4.6 High as the coder/worker/reviewer when available.
- Use Haiku 4.5 as a code reader when useful.
- Implement only the approved slice.
- Keep the diff small.
- Preserve current behavior unless explicitly instructed otherwise.
- Do not broaden scope.
- Do not change dependencies unless approved.
- Do not change database schema unless approved.
- Do not redesign UI unless this slice is specifically a UI redesign.
- Add or update tests where needed.
- Run verification commands.

Use subagents when useful:
- `sonnet-implementation-worker` for focused implementation.
- `haiku-code-reader` for reference tracing and diff review.

After implementation, report:

## Slice Complete

### Files changed

### What changed

### Behavior preservation

### Tests added or updated

### Verification

Report:
- npm run typecheck
- npm run lint
- npm run test:unit
- npm run build

### Follow-up risks

Stop after this slice.