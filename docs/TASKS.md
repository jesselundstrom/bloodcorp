# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total — compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

## Next

## Later

- **Equipment / weapon shop** - Gear items with damage dice, armor_bonus, attack stat (STR/DEX/finesse), action options, and passive effects in Management. Equip slots per gladiator. **Unblocker for item-use bonus actions.** Shown on gladiator cards and surfaced during battle when gear grants usable skills.
- **Augmentation system** - Data model for cyberware slots, shop UI tab in Management, INT-driven skill effects applied when Battle builds unit stats. Depends on skill/stat-modifier data model from the skills refactor — design with aug hooks in mind.
- **Defensive stance / parry** - Bonus action for a defensive posture (damage reduction, counter, or parry — imposes disadvantage on next incoming attack roll). Re-evaluate after D&D resolution is in place.
- **CHA / style scoring hooks** - CHA_mod adds to style score per kill; crowd reaction log flair gated on CHA threshold; sponsor contracts can reference style beyond kills and rounds.
- **Gladiator pixel sprites** - Improve the current `gladiators.png` TextureRect/AtlasTexture setup into a future-ready Sprite2D/AnimatedSprite2D pattern with clearer placeholder pixel art and animation hooks.
- **Game-over / campaign structure** - Lose condition when credits drop to 0 (or below hire cost). Day/season loop with escalating enemy stat scaling. A "next contract" flow after each win.
- **Battle polish** - Smarter arena readability and spectacle. Next: stronger formation variety, at least one special ability per unit type, and a crowd-style score shown to sponsor.
- **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX in Battle. `assets/audio/` folder TBD.
- **Facility upgrades** - Spend credits between battles on training room (+stat cap), med bay (heal injured), comms suite (better recruits). New UI section in Management.

---

## Done

- **Project scaffold** - Godot 4.6, GL Compatibility renderer, Jolt Physics, godot_ai MCP plugin wired up, GameState autoload *(e9a9f50, 4600e1b)*
- **Full game loop** - Main menu, Management scene (roster/recruit/hire/fire/credits), isometric turn-based Battle (speed-initiative, targeting, damage, HP bars), Result screen with credit reward/penalty, loop back to Management *(7b760ec - 67a1d98)*
- **Save / Load** - `GameState.save_game/load_game/has_save`; auto-saves on hire/fire and after battle result; Continue button enabled only when save exists
- **Sponsor system** - SponsorSelect screen; three contract types (kills, style/rounds, target priority); dynamic reward/penalty; mark highlighting in arena
- **Tactical movement foundation** - Battle grid expanded to 7x5; units get move/action state; player turns support clickable movement and melee-only attacks; enemy AI advances toward nearest target; SponsorSelect double-parent UI bug fixed
- **Action economy** - `has_moved/has_main_action/has_bonus_action` per unit with turn reset; attacks consume main action; Shove (all units) and Execution Mark (roster skill) as bonus actions; Brutal Charge as skill-gated main action; Marksman as passive range upgrade; action bar shows MOVE/ACTION/BONUS state. *(Item use and defensive stance deferred — no backing data; unified bonus UI deferred to skills refactor)*
- **Style scoring display** - `_style_score` shown on all three contract types; `★ THE CROWD ROARS! ★` log flair on Execution Mark kills
- **Pixel font** - m5x7 pixel font imported; applied globally via `assets/theme/bloodcorp.tres` set as `gui/theme/custom` in project settings
- **Gladiator stat block** - STR_score/DEX/CON/INT/CHA (8-18) added to all gladiator dicts; `_stat_mod()` helper uses float-floor; `hp_max = 8 + CON_mod`; `defense_class = 10 + DEX_mod + armor`; old saves backfilled with 10 defaults
- **D&D-style attack resolution** - `1d20 + attack_bonus vs DC`; hit/miss/crit (nat 20 = double dice); flanking + mark → advantage (binary, 2d20 take high); `1d6+STR_mod` melee / `1d8+DEX_mod` ranged; proficiency +2 (recruit placeholder); min 1 damage on hit; `MARK_BONUS`/`FLANK_BONUS` removed; mark now advantage-only (no bonus damage)
- **Data-driven skill refactor** - `SkillData.gd` defines Brutal Charge / Marksman / Execution Mark / Shove with display_name, description, action_cost, valid_targets, attack_stat, cooldown; `_build_units()` reads from `SkillData` via fallback index array; identical in-battle behavior preserved; BtnShove+BtnMark replaced with single BtnBonus+PopupMenu unified bonus action UI
- **4th skill archetype + skill info UI** - Shield Bash (bonus action, 2 dmg, requires adjacent enemy) added to `SkillData.gd` as 4th identity skill; assigned to gladiator index 3 in `_DEFAULT_SKILL_BY_INDEX`; popup label logic made data-driven via `valid_targets` field; HUD skill display now shows `SKILL[ACTION/BONUS/PASSIVE]:` cost type label for all units
