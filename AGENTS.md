# AGENTS.md

This project also uses `CLAUDE.md` as the shared agent guide.
Read `CLAUDE.md` before making code changes.

## Codex Notes

- Always use Godot MCP tools when applicable for Godot work: scene/node changes, script work that benefits from editor context, asset/resource inspection, and runtime verification.
- Keep implementation slices small and focused.
- Prefer the existing project style over new abstractions.
- Keep `CLAUDE.md`, `docs/GAME_DESIGN.md`, `docs/TASKS.md`, and relevant design docs up to date when code changes alter behavior, architecture, workflow, design direction, or completed task status.
- Do not modify files under `addons/godot_ai/`; it is third-party tooling.
- Treat `CLAUDE.md` as the shared agent/workflow guide. Treat `docs/GAME_DESIGN.md` as the source of truth for broad game vision, player-facing design direction, tone, and major game decisions.
