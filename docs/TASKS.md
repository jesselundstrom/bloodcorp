# Bloodcorp - Task List

Agent instructions: When tasks complete, move them to **Done**. Summarise batches of >=3 related items into one line. Keep Done to <=10 lines total - compress the oldest entries first.

---

## Backlog

1. **Tactical arena combat direction** - Action bar, obstacle tiles, Shove/wall damage, flanking bonus (+3 dmg when sandwiched), Brutal Charge (roster[0]), Marksman (roster[1]), and Execution Mark (roster[2] bonus-action marks a wounded adjacent enemy for +2 damage and a style point on kill) are in. Style score tracked in `_style_score` and shown in objective label. Next: fourth skill archetype, richer crowd/style scoring display. See `docs/COMBAT_DESIGN.md`.

3. **Action economy** - Expand the current combat state into a full action model. Battle units now reserve `has_main_action`, `has_bonus_action`, and `has_moved`; basic attacks consume the main action and movement is once per turn. Next: expose bonus actions, skills, item use, and defensive choices in the UI.

4. **Character-specific skills** - Give gladiators build-defining active skills, passive traits, or cyberware abilities. Skills should be data-driven enough to show names, descriptions, costs, cooldowns, and valid targets in the battle UI.

5. **Augmentation system** - Data model for cyberware slots, a shop UI tab in Management, stat modifiers (e.g. +STR, +SPD) applied when Battle builds unit stats. Core to the cyberpunk identity of the game.

6. **Gladiator pixel sprites** - Improve the current `gladiators.png` TextureRect/AtlasTexture setup into a future-ready Sprite2D/AnimatedSprite2D pattern with clearer placeholder pixel art and animation hooks.

7. **Pixel font** - Import a pixel/bitmap font and apply it globally. `assets/fonts/` is empty. Affects all labels across Menu, Management, and Battle.

8. **Game-over / campaign structure** - Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.

9. **Battle polish** - Smarter arena readability and spectacle. Basic left/right deployment is improved; next add terrain/obstacle tiles, stronger formation variety, at least one special ability per unit type, and a crowd-style score shown to sponsor.

10. **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.

11. **Facility upgrades** - Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.

12. **Equipment / weapon shop** - Gear items with stat modifiers, action options, and passive effects available in Management. Equip slots per gladiator. Shown on gladiator cards and surfaced during battle when gear grants usable skills.

---

## Done

- **Project scaffold** - Godot 4.6, GL Compatibility renderer, Jolt Physics, godot_ai MCP plugin wired up, GameState autoload *(e9a9f50, 4600e1b)*
- **Full game loop** - Main menu, Management scene (roster/recruit/hire/fire/credits), isometric turn-based Battle (speed-initiative, targeting, damage, HP bars), Result screen with credit reward/penalty, loop back to Management *(7b760ec - 67a1d98)*
- **Save / Load** - `GameState.save_game/load_game/has_save`; auto-saves on hire/fire and after battle result; Continue button enabled only when save exists
- **Sponsor system** - SponsorSelect screen; three contract types (kills, style/rounds, target priority); dynamic reward/penalty; mark highlighting in arena
- **Tactical movement foundation** - Battle grid expanded to 7x5; units get move/action state; player turns support clickable movement and melee-only attacks; enemy AI advances toward nearest target; SponsorSelect double-parent UI bug fixed
- **Tactical combat iteration** - Action bar shows MOVE/ACTION/BONUS state; 5 midfield obstacle tiles block movement for both player and enemy AI; Shove bonus action pushes adjacent enemies one tile away and is consumed once per turn; Execution Mark (roster[2]) marks a wounded adjacent enemy as a bonus action — +2 dmg and style point on kill
