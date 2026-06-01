# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.6 game project named **bloodcorp**. Core game loop is playable end-to-end: Menu -> Management -> SponsorSelect -> Battle -> Result -> Management.

## Running the Project

Open `project.godot` in the Godot 4.6 editor. Run the project with **F5** (run project) or **F6** (run current scene). There is no CLI build step.

## Project Configuration

- **Renderer:** GL Compatibility (D3D12 on Windows)
- **Physics:** Jolt Physics (3D)
- **Autoload:** `_mcp_game_helper` - injected by the `godot_ai` plugin for AI tooling; do not remove

## AI Development Tooling

The `addons/godot_ai` plugin runs a local MCP server that lets AI assistants inspect and modify the live Godot editor via WebSocket. It is enabled in Project Settings and auto-starts when the editor opens.

**Do not modify files under `addons/godot_ai/`** - this is a third-party plugin. Its source is at github.com/hi-godot/godot-ai.

When connected via MCP, prefer Godot MCP tools for scenes, nodes, scripts, and runtime verification. Direct file edits are acceptable for focused script/doc changes, but scene and node mutations should go through the editor when practical.

## Game: Bloodcorp

A dystopian gladiator manager game with cyberpunk/WH40k aesthetics.

### Concept

- Player manages a gladiator team sponsored by megacorporations.
- Sponsors set match requirements such as kill count, style/round limits, or priority targets.
- Isometric 2D pixel-art battles use a compact tactical grid.
- Tactical combat is evolving toward Arena 8-style fights with limited cRPG-style movement, action/bonus action choices, character-specific skills, and equipment-driven abilities.
- Gladiators can eventually have cybernetic augmentations.

### Visual Style

- Dark background (#0a0a0f)
- Neon red accent (#ff2244)
- Cyber cyan for augments (#00ffcc)
- Amber warnings (#ffaa00)
- Pixel art sprites, CRT scanline effect
- Isometric perspective for battle scenes

### Current Implementation Notes

- Battle uses a 7x5 isometric grid with bounded left/right deployment.
- Player turns support clickable highlighted movement tiles, one movement, and melee-only basic attacks.
- Battle units currently reserve `move_range`, `attack_range`, `has_moved`, `has_main_action`, and `has_bonus_action`.
- Enemy AI advances toward the nearest living player, then attacks if in melee range.
- Sponsor objectives are tracked during Battle; result rewards/penalties are based on the selected sponsor contract.
- `SponsorSelect.gd` builds its UI in script; keep parent/child ownership simple because the scene root itself has no authored children.

### Architecture

**Scenes & Scripts (one script per scene):**

- `scenes/Main.tscn` / `scripts/Main.gd` - Entry point; routes immediately to Menu.
- `scenes/Menu.tscn` / `scripts/Menu.gd` - Main menu with New Game / Continue / Quit.
- `scenes/Management.tscn` / `scripts/Management.gd` - Roster management, random recruit pool, hire/fire, deploy to sponsor selection.
- `scenes/SponsorSelect.tscn` / `scripts/SponsorSelect.gd` - Sponsor contract selection before battle.
- `scenes/Battle.tscn` / `scripts/Battle.gd` - Speed-sorted initiative, isometric movement grid, melee targeting, damage formula (STR - ARM), sponsor tracking, result overlay.
- `scripts/GameState.gd` - Global Autoload; holds credits, roster array, active_sponsor, current_day, and save/load state.

**Assets:**

- `assets/sprites/gladiators.png` - Current gladiator sprite sheet used by Battle via TextureRect/AtlasTexture frames.
- `assets/sprites/menu_bg.png` - Main menu background.
- `assets/fonts/` - Pixel fonts are still TBD.

**Task backlog:** see `docs/TASKS.md`

**Combat design direction:** see `docs/COMBAT_DESIGN.md`

### Development Style

- Use Godot MCP tools to create nodes and scenes in the live editor.
- Keep scripts modular - one responsibility per file.
- Use `GameState.gd` as the global Autoload for persistent data.
- Keep implementation slices small and focused.
- Keep `CLAUDE.md`, `docs/TASKS.md`, and relevant design docs up to date when code changes alter behavior, architecture, workflow, or completed task status.
