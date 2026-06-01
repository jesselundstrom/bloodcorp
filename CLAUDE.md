# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Godot 4.6 game project named **bloodcorp**. Currently in early development — no scenes or game scripts exist yet.

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
- `scenes/` — Main, Menu, Management, Battle
- `scripts/` — GDScript logic files
- `assets/sprites/` — Pixel art sprites
- `assets/fonts/` — Pixel fonts

### Development Style
- Use Godot MCP tools to create nodes and scenes in the live editor
- Keep scripts modular — one responsibility per file
- GameState.gd as global Autoload for persistent data