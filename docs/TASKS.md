# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total - compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

## Next

- **Rank / tier system** - Gladiator rank (recruit/veteran/champion) unlocks proficiency +3/+4 and stat progression; prerequisite for equipment system.

## Later

- **Equipment / weapon shop** - Gear items with damage dice, armor_bonus, attack stat (STR/DEX/finesse), action options, and passive effects in Management. Equip slots per gladiator. **Unblocker for item-use bonus actions.** Shown on gladiator cards and surfaced during battle when gear grants usable skills.
- **Augmentation system** - Data model for cyberware slots, shop UI tab in Management, INT-driven skill effects applied when Battle builds unit stats. Depends on skill/stat-modifier data model from the skills refactor - design with aug hooks in mind.
- **Defensive stance / parry** - Bonus action for a defensive posture (damage reduction, counter, or parry - imposes disadvantage on next incoming attack roll). Re-evaluate after D&D resolution is in place.
- **CHA / style scoring hooks** - CHA_mod adds to style score per kill; crowd reaction log flair gated on CHA threshold; sponsor contracts can reference style beyond kills and rounds.
- **Gladiator pixel sprites** - Improve the current `gladiators.png` TextureRect/AtlasTexture setup into a future-ready Sprite2D/AnimatedSprite2D pattern with clearer placeholder pixel art and animation hooks.
- **Game-over / campaign structure** - Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.
- **Battle polish** - Smarter arena readability and spectacle. Next: stronger enemy formation variety, enemy specials, and crowd-style hooks.
- **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.
- **Facility upgrades** - Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.

---

## Done

- **Project scaffold + full loop** - Godot 4.6 project, GameState autoload, Menu -> Management -> SponsorSelect -> Battle -> Result -> Management playable loop *(e9a9f50 - 67a1d98)*
- **Save / Load + sponsor contracts** - save/load/continue flow; SponsorSelect with kills, style/rounds, target-priority contracts; battle result rewards/penalties
- **Tactical movement + action economy foundation** - 7x5 isometric grid, movement/action/bonus state, clickable moves, melee targeting, Shove, Execution Mark, Brutal Charge, Marksman, enemy advance AI
- **Style scoring display** - `_style_score` shown on all three contract types; crowd reaction log flair on Execution Mark kills
- **Pixel font** - m5x7 pixel font imported; applied globally via `assets/theme/bloodcorp.tres` set as `gui/theme/custom` in project settings
- **Gladiator stat block + D&D-style attack resolution** - STR/DEX/CON/INT/CHA, HP/DC formulas, d20 attacks, hit/miss/crit, flanking/mark advantage, melee/ranged damage dice
- **Data-driven skill refactor** - `SkillData.gd` defines Brutal Charge / Marksman / Execution Mark / Shove with display_name, description, action_cost, valid_targets, attack_stat, cooldown; `_build_units()` reads from `SkillData`; BtnShove+BtnMark replaced with single BtnBonus+PopupMenu unified bonus action UI
- **4th skill archetype + skill info UI** - Shield Bash added as a bonus-action identity skill; fallback assignment updated; HUD skill display shows cost type label for all units
- **Arena planning feel** - Battle grid expanded to 9x6; three arena layouts select blockers, hazards, and spawns; movement uses path-aware BFS; Shove distinguishes impact type and hazard shoves deal 2 damage + STYLE +1
