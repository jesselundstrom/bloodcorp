# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total — compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

- **Action economy** - Full action model in battle UI.
  - [x] `has_main_action`, `has_bonus_action`, `has_moved` reserved on all units
  - [x] Basic attacks consume main action; movement once per turn
  - [x] Action bar shows MOVE / ACTION / BONUS state in unit info label
  - [x] Shove bonus action wired up (consumes `has_bonus_action`)
  - [x] Execution Mark bonus action wired up (consumes `has_bonus_action`)
  - [ ] Additional bonus action types: item use, defensive choices
  - [ ] Bonus action selection surfaced clearly in UI (beyond per-skill buttons)

## Next

- **Character-specific skills** - Give gladiators build-defining active skills, passive traits, or cyberware abilities.
  - [ ] Data-driven skill definition (name, description, cost, cooldown, valid targets)
  - [ ] 4th skill archetype (first three: Brutal Charge, Marksman, Execution Mark)
  - [ ] Skill names, costs, and cooldowns shown in battle UI per unit
- **Style scoring display** - Richer crowd/style feedback in the arena.
  - [x] `_style_score` tracked and shown in objective label on kills contract
  - [ ] Style score visible on all contract types
  - [ ] Crowd reaction visual or log flair tied to style events

## Later

- **Augmentation system** - Data model for cyberware slots, a shop UI tab in Management, stat modifiers (e.g. +STR, +SPD) applied when Battle builds unit stats. Core to the cyberpunk identity of the game.
- **Gladiator pixel sprites** - Improve the current `gladiators.png` TextureRect/AtlasTexture setup into a future-ready Sprite2D/AnimatedSprite2D pattern with clearer placeholder pixel art and animation hooks.
- **Game-over / campaign structure** - Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.
- **Battle polish** - Smarter arena readability and spectacle. Next: stronger formation variety, at least one special ability per unit type, and a crowd-style score shown to sponsor.
- **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.
- **Facility upgrades** - Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.
- **Equipment / weapon shop** - Gear items with stat modifiers, action options, and passive effects available in Management. Equip slots per gladiator. Shown on gladiator cards and surfaced during battle when gear grants usable skills.

---

## Done

- **Project scaffold** - Godot 4.6, GL Compatibility renderer, Jolt Physics, godot_ai MCP plugin wired up, GameState autoload *(e9a9f50, 4600e1b)*
- **Full game loop** - Main menu, Management scene (roster/recruit/hire/fire/credits), isometric turn-based Battle (speed-initiative, targeting, damage, HP bars), Result screen with credit reward/penalty, loop back to Management *(7b760ec - 67a1d98)*
- **Save / Load** - `GameState.save_game/load_game/has_save`; auto-saves on hire/fire and after battle result; Continue button enabled only when save exists
- **Sponsor system** - SponsorSelect screen; three contract types (kills, style/rounds, target priority); dynamic reward/penalty; mark highlighting in arena
- **Tactical movement foundation** - Battle grid expanded to 7x5; units get move/action state; player turns support clickable movement and melee-only attacks; enemy AI advances toward nearest target; SponsorSelect double-parent UI bug fixed
- **Tactical combat iteration** - Action bar shows MOVE/ACTION/BONUS state; 5 midfield obstacle tiles block movement for both player and enemy AI; Shove bonus action pushes adjacent enemies one tile away; Execution Mark (roster[2]) marks a wounded adjacent enemy as a bonus action — +2 dmg and style point on kill
- **Pixel font** - m5x7 pixel font imported; applied globally via `assets/theme/bloodcorp.tres` set as `gui/theme/custom` in project settings
