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

Three MCP servers are available to AI agents working on this project:

### godot-ai (Godot editor control)
The `addons/godot_ai` plugin runs a local MCP server that lets AI assistants inspect and modify the live Godot editor via WebSocket. It is enabled in Project Settings and auto-starts when the editor opens.

**Do not modify files under `addons/godot_ai/`** - this is a third-party plugin. Its source is at github.com/hi-godot/godot-ai.

When connected via MCP, always use Godot MCP tools when applicable for Godot work: scene/node changes, script work that benefits from editor context, asset/resource inspection, and runtime verification. Direct file edits are acceptable for focused script/doc changes, but scene and node mutations should go through the editor when practical.

### replicate (AI image generation)
Replicate MCP is configured in `.claude/.mcp.json` (gitignored). Use it for concept art, background images, and reference generation via `flux-schnell` or other models. Good for fast iteration but not suited for precise pixel art game sprites.

### pixellab (pixel art asset generation)
PixelLab MCP is configured via `claude mcp add` (stored in `~/.claude.json`). Use it for all pixel art game assets:
- `create_character` — gladiator/enemy sprites, 4 or 8 directional views, up to 128px
- `animate_character` — walk, attack, death, idle animation frames
- `create_isometric_tile` — arena floor and wall tiles
- `create_topdown_tileset` / `create_sidescroller_tileset` — map tilesets
- `create_character_state` — per-state sprite variants (e.g. downed, armored)

Prefer PixelLab over Replicate for any sprite or tile work. Assets should be saved to `assets/sprites/`. Account is on a trial plan — check balance with `get_balance` before batch generation.

## Game: Bloodcorp

A dystopian gladiator manager game with cyberpunk/WH40k aesthetics.

**Game design source of truth:** see `docs/GAME_DESIGN.md` for broad game vision, player fantasy, core loop, management/sponsor/progression direction, tone, and major design decisions. Keep that file updated when work changes major player-facing game design.

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

- Battle uses a configurable 13x9 logical isometric grid projected through an ellipse mask; the grid is now a mostly hidden tactical substrate so arena movement reads more free-form until contextual overlays appear.
- Arena layouts define blockers, rough/raised/high terrain, ramp paths between elevation levels, Plasma Vent hazards with round-based phases, player spawns, and enemy spawns.
- Player turns support movement-cost-aware contextual movement reticles, one movement, and melee-only basic attacks unless a skill or elevation changes range.
- Battle units currently reserve `move_range`, `attack_range`, `has_moved`, `has_main_action`, `has_bonus_action`, and `roster_index` (links back to `GameState.roster` for casualty resolution).
- Player gladiators reaching 0 HP are **downed** (removed from battle, survive to post-battle d10 casualty roll); enemies die immediately as before.
- Post-battle casualty roll: d10 — 1=death, 2–4=serious injury, 5–10=minor injury. Injuries are data-driven in `scripts/InjuryData.gd` and stored as `roster[i]["injuries"]` (array of `{key, remaining}` dicts). `GameState.tick_injuries()` decrements recovery once per battle (in `_show_result`, before `save_game()`).
- Enemy AI advances toward the nearest living player using reachable movement tiles, then attacks if in range.
- `speed` now derives default movement distance (1-3 => 2, 4-6 => 3, 7-9 => 4, 10+ => 5), while explicit `move_range` remains an override for future equipment/skills.
- Higher elevation grants a small attack/range edge; attacking uphill has a small penalty. Normal movement changes elevation only through ramp-linked paths. Forced movement from higher to lower elevation causes fall damage.
- Shove can push enemies, slam them into walls/blockers/units, trigger active Plasma Vents, cause fall damage, or ring out targets at lethal arena edges.
- Sponsor objectives are tracked during Battle; result rewards/penalties are based on the selected sponsor contract.
- `SponsorSelect.gd` builds its UI in script; keep parent/child ownership simple because the scene root itself has no authored children.

### Architecture

**Scenes & Scripts (one script per scene):**

- `scenes/Main.tscn` / `scripts/Main.gd` - Entry point; routes immediately to Menu.
- `scenes/Menu.tscn` / `scripts/Menu.gd` - Main menu with New Game / Continue / Quit.
- `scenes/Management.tscn` / `scripts/Management.gd` - Roster management, random recruit pool, hire/fire, deploy to sponsor selection.
- `scenes/SponsorSelect.tscn` / `scripts/SponsorSelect.gd` - Sponsor contract selection before battle.
- `scenes/Battle.tscn` / `scripts/Battle.gd` - Speed-sorted initiative, isometric movement grid, melee targeting, damage formula (STR - ARM), sponsor tracking, result overlay.
- `scripts/GameState.gd` - Global Autoload; holds credits, roster array, active_sponsor, current_day, and save/load state. Injury API: `apply_injury`, `kill_gladiator`, `tick_injuries`, `heal_injury_immediate`.
- `scripts/InjuryData.gd` - Static data for the three injury types (Broken Arm, Damaged Optic, Cracked Plating); stat penalties, HP penalty, recovery duration.

**Assets:**

- `assets/sprites/gladiators.png` - Current gladiator sprite sheet used by Battle via TextureRect/AtlasTexture frames.
- `assets/sprites/menu_bg.png` - Main menu background.
- `assets/fonts/` - Pixel fonts are still TBD.

**Task backlog:** see `docs/TASKS.md`

**Combat design direction:** see `docs/COMBAT_DESIGN.md`

**Game design direction:** see `docs/GAME_DESIGN.md`

### Development Style

- Always use Godot MCP tools when applicable for Godot scenes, nodes, scripts, assets/resources, and runtime verification.
- Keep scripts modular - one responsibility per file.
- Use `GameState.gd` as the global Autoload for persistent data.
- Keep implementation slices small and focused.
- Keep `CLAUDE.md`, `docs/GAME_DESIGN.md`, `docs/COMBAT_DESIGN.md`, `docs/TASKS.md`, and relevant design docs up to date when code changes alter behavior, architecture, workflow, design direction, or completed task status.
