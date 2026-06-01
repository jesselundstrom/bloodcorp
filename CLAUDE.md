# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.6 game project named **bloodcorp**. Core game loop is playable end-to-end: Menu → Management → Battle → Result → Management.

## Running the Project

Open `project.godot` in the Godot 4.6 editor. Run the project with **F5** (run project) or **F6** (run current scene). There is no CLI build step.

## Project Configuration

- **Renderer:** GL Compatibility (D3D12 on Windows)
- **Physics:** Jolt Physics (3D)
- **Autoload:** `_mcp_game_helper` — injected by the `godot_ai` plugin for AI tooling; do not remove

## AI Development Tooling (godot_ai plugin)

The `addons/godot_ai` plugin runs a local MCP server that lets AI assistants (Claude Code, Codex, etc.) inspect and modify the live Godot editor via WebSocket. It is enabled in Project Settings and auto-starts when the editor opens.

**Do not modify files under `addons/godot_ai/`** — this is a third-party plugin. Its source is at [github.com/hi-godot/godot-ai](https://github.com/hi-godot/godot-ai).

When Claude Code is connected via the MCP server, prefer using the Godot MCP tools (`node_create`, `scene_manage`, `script_create`, etc.) to make changes in the live editor rather than writing `.tscn` or `.gd` files directly on disk, since Godot parses and imports resources through the editor.

## Game: Bloodcorp

A dystopian gladiator manager game with cyberpunk/WH40k aesthetics.

### Concept
- Player manages a gladiator team sponsored by megacorporations
- Isometric 2D pixel art battles (team vs team, simultaneous)
- Tactical arena combat should evolve toward compact Arena 8-style fights with limited cRPG-style movement, action/bonus action choices, character-specific skills, and equipment-driven abilities
- Corp sponsors set match requirements (kill count, style, specific targets)
- Gladiators can have cybernetic augmentations

### Visual Style
- Dark background (#0a0a0f)
- Neon red accent (#ff2244)
- Cyber cyan for augments (#00ffcc)
- Amber warnings (#ffaa00)
- Pixel art sprites, CRT scanline effect
- Isometric perspective for battle scenes

### Architecture

**Scenes & Scripts (one script per scene):**
- `scenes/Main.tscn` / `scripts/Main.gd` — Entry point; routes immediately to Menu
- `scenes/Menu.tscn` / `scripts/Menu.gd` — Main menu with New Game / Continue / Quit
- `scenes/Management.tscn` / `scripts/Management.gd` — Roster management, random recruit pool, hire/fire, deploy to arena
- `scenes/Battle.tscn` / `scripts/Battle.gd` — Turn-based combat: speed-sorted initiative, isometric grid, damage formula (STR − ARM), result overlay
- `scripts/GameState.gd` — Global Autoload; holds credits, roster array, active_sponsor, current_day

**Assets (currently empty placeholders):**
- `assets/sprites/` — Pixel art sprites (not yet populated)
- `assets/fonts/` — Pixel fonts (not yet populated)

**Task backlog:** see [docs/TASKS.md](docs/TASKS.md)

**Combat design direction:** see [docs/COMBAT_DESIGN.md](docs/COMBAT_DESIGN.md)

### Development Style
- Use Godot MCP tools to create nodes and scenes in the live editor
- Keep scripts modular — one responsibility per file
- GameState.gd as global Autoload for persistent data
