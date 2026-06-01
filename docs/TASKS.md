# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total — compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

- **Gladiator stat block** - Add STR/DEX/CON/INT/CHA to gladiator data dict; compute stat modifiers (`floor((stat-10)/2)`); replace legacy HP formula (`20 + armor*2`) with `8 + CON_mod`. Gate for D&D-style resolution.
  - [ ] Stat fields added to gladiator dicts in GameState and Management recruit pool
  - [ ] `_build_units()` reads stat block and computes modifiers
  - [ ] HP uses CON_mod formula; displayed correctly on HP bars
  - [ ] Defense Class computed from DEX_mod + armor_bonus

## Next

- **D&D-style attack resolution** - Replace `max(1, STR - ARM)` placeholder with `1d20 + attack_bonus vs target.DC`. Hit/miss/crit. Flanking → advantage (2d20 high). Execution Mark → advantage. Damage dice + stat mod. See COMBAT_DESIGN.md for full spec.
  - [ ] Attack roll function: `1d20 + attack_bonus >= target.DC`
  - [ ] Miss: no damage; hit: damage dice + stat_mod; crit (natural 20): double dice
  - [ ] Flanking uses advantage (2d20 take high) instead of flat +3
  - [ ] Execution Mark uses advantage instead of flat +2
  - [ ] Proficiency bonus tier: +2 recruit / +3 veteran / +4 champion

- **Character-specific skills — data-driven refactor** - Replace hardcoded roster-index skill assignment with a skill data structure. Include `attack_stat` field (STR/DEX/INT) now that the stat block exists. Gating dependency for 4th archetype, skill UI, unified bonus UI, and equipment/augmentation hooks.
  - [ ] Define skill data dict (name, description, action_cost, cooldown, valid_targets, attack_stat)
  - [ ] Refactor `_build_units()` to read from skill data instead of hardcoded index logic
  - [ ] Three existing skills (Brutal Charge, Marksman, Execution Mark) produce identical in-battle behavior — pure refactor, no behavior change
  - [ ] Unified bonus action selection UI (natural payoff once multiple bonus actions share a model)

- **4th skill archetype + skill info UI** - New archetype using the data model above; skill details surfaced to player.
  - [ ] 4th skill archetype implemented
  - [ ] Skill names, costs, and cooldowns shown in battle UI per unit

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
