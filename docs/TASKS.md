# Bloodcorp — Task List

Agent instructions: When tasks complete, move them to **Done**. Summarise batches of ≥3 related items into one line. Keep Done to ≤10 lines total — compress the oldest entries first.

---

## Backlog

1. **Tactical arena combat direction** — Evolve battles toward an Arena 8-style tactical combat format: compact arena fights with limited cRPG-style movement, positioning choices, and readable turn flow inspired by Baldur's Gate 3. See `docs/COMBAT_DESIGN.md`.

3. **Action economy** — Add a combat action model with one main action and one bonus action per active gladiator. Attacks, movement, skills, item use, and defensive choices should consume the correct action type.

4. **Character-specific skills** — Give gladiators build-defining active skills, passive traits, or cyberware abilities. Skills should be data-driven enough to show names, descriptions, costs, cooldowns, and valid targets in the battle UI.

5. **Augmentation system** — Data model for cyberware slots, a shop UI tab in Management, stat modifiers (e.g. +STR, +SPD) applied when Battle builds unit stats. Core to the cyberpunk identity of the game.

6. **Gladiator pixel sprites** — Replace the flat ColorRect squares in Battle with actual sprite nodes. `assets/sprites/` is empty. Start with placeholder 16×16 or 32×32 art; define the Sprite2D/AnimatedSprite2D pattern for future animation.

7. **Pixel font** — Import a pixel/bitmap font and apply it globally. `assets/fonts/` is empty. Affects all labels across Menu, Management, and Battle.

8. **Game-over / campaign structure** — Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.

9. **Battle polish** — Smarter unit placement (spread across grid, not hard-coded corners), at least one special ability per unit type, a crowd-style score shown to sponsor, basic terrain/obstacle tiles.

10. **Audio** — AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.

11. **Facility upgrades** — Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.

12. **Equipment / weapon shop** — Gear items with stat modifiers, action options, and passive effects available in Management. Equip slots per gladiator. Shown on gladiator cards and surfaced during battle when gear grants usable skills.

---

## Done

- **Project scaffold** — Godot 4.6, GL Compatibility renderer, Jolt Physics, godot_ai MCP plugin wired up, GameState autoload *(e9a9f50, 4600e1b)*
- **Full game loop** — Main menu, Management scene (roster/recruit/hire/fire/credits), isometric turn-based Battle (speed-initiative, targeting, damage, HP bars), Result screen with credit reward/penalty, loop back to Management *(7b760ec – 67a1d98)*
- **Save / Load** — `GameState.save_game/load_game/has_save`; auto-saves on hire/fire and after battle result; Continue button enabled only when save exists
- **Sponsor system** — SponsorSelect screen; three contract types (kills, style/rounds, target priority); dynamic reward/penalty; mark highlighting in arena
