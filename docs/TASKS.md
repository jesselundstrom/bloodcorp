# Bloodcorp — Task List

Agent instructions: When tasks complete, move them to **Done**. Summarise batches of ≥3 related items into one line. Keep Done to ≤10 lines total — compress the oldest entries first.

---

## Backlog

1. **Sponsor system** — Let player pick a sponsor before battle. Display contract requirements (kill count, style rating, target priority). Track fulfilment during battle. Apply bonus/penalty on top of base reward. `GameState.active_sponsor` is already stubbed.

3. **Augmentation system** — Data model for cyberware slots, a shop UI tab in Management, stat modifiers (e.g. +STR, +SPD) applied when Battle builds unit stats. Core to the cyberpunk identity of the game.

4. **Gladiator pixel sprites** — Replace the flat ColorRect squares in Battle with actual sprite nodes. `assets/sprites/` is empty. Start with placeholder 16×16 or 32×32 art; define the Sprite2D/AnimatedSprite2D pattern for future animation.

5. **Pixel font** — Import a pixel/bitmap font and apply it globally. `assets/fonts/` is empty. Affects all labels across Menu, Management, and Battle.

6. **Game-over / campaign structure** — Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.

7. **Battle polish** — Smarter unit placement (spread across grid, not hard-coded corners), at least one special ability per unit type, a crowd-style score shown to sponsor, basic terrain/obstacle tiles.

8. **Audio** — AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.

9. **Facility upgrades** — Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.

10. **Equipment / weapon shop** — Gear items with stat modifiers available in Management. Equip slots per gladiator. Shown on gladiator cards.

---

## Done

- **Project scaffold** — Godot 4.6, GL Compatibility renderer, Jolt Physics, godot_ai MCP plugin wired up, GameState autoload *(e9a9f50, 4600e1b)*
- **Full game loop** — Main menu, Management scene (roster/recruit/hire/fire/credits), isometric turn-based Battle (speed-initiative, targeting, damage, HP bars), Result screen with credit reward/penalty, loop back to Management *(7b760ec – 67a1d98)*
- **Save / Load** — `GameState.save_game/load_game/has_save`; auto-saves on hire/fire and after battle result; Continue button enabled only when save exists
