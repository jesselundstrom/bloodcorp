# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total - compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

- **Casualty Resolution + injuries** - Change 0 HP from "dead" to "downed". Downed player gladiators leave the current battle but survive to a post-battle casualty roll (mostly injury, rarely death; enemies just die). Data-driven injury model with stat/HP penalties, recovery over matches, and instant med-bay heal for credits. Concurrent-injury cap. Foundational to the churn feel; de-risks d20 variance. See `COMBAT_DESIGN.md` "Casualty Resolution".

## Next

- **Service clock + development ticks** - Per-gladiator Service counter (matches fought), grouped into Seasons. Post-battle development tick that rolls stat increases toward a hidden `ceiling` per current stage. Player sees stats rise; ceiling stays hidden. GameState's existing day/round counter can seed the Service clock.
- **Development arc data model** - Hidden `ceiling` + arc shape (when growth is fast, when peak hits, when decline starts) + career stage (Prospect/Rising/Prime/Decline/Spent). Stages drive growth, decline erosion, and casualty risk. Ceiling correlates *loosely* with starting stats.

## Later

- **Fuzzy Projection + scouting** - Visible potential estimate shown as a band/grade (not exact). Scouting (credits / comms suite) narrows the band and may reveal a trait. This is the player's agency lever at the draft.
- **Traits** - Data-driven traits that shape the arc and give scouting something to reveal (Prodigy, Late Bloomer, Workhorse, Journeyman, Glass, Burnout). Some visible at recruit, some scout-gated.
- **Decline decisions** - Actions on a declining/Spent gladiator: retire for salvage payout, deploy on a high-risk "last contract", or assign to training room as a trainer.
- **Rank / tier system** - Recruit/veteran/champion unlocks proficiency +3/+4 and stat progression; prerequisite for equipment.
- **Economy spine / balance pass** - Set first-pass numbers: hire cost, per-match upkeep, contract payouts by division, salvage curve, scouting/med-bay/equipment/augment/facility costs. The actual backbone of progression; tune as a deliberate pass once the systems above exist.
- **Facility upgrades** - Training room (development/trainer slot), med bay (heal injuries), comms suite (scouting/better recruits). New UI section in Management.
- **Campaign / season structure** - Division progression, Season blocks of matches, escalating enemy stat scaling, "next contract" flow, and loss conditions (insolvency; later, reputation collapse).
- **Equipment / weapon shop** - Gear with damage dice, armor_bonus, attack stat (STR/DEX/finesse), action options, passive effects. Equip slots per gladiator. Unblocks item-use bonus actions.
- **Augmentation system** - Cyberware slots, shop tab in Management, INT-driven skill effects applied when Battle builds unit stats. Design with the skill/stat-modifier data model in mind.
- **CHA / style scoring hooks** - CHA_mod adds to style score per kill; crowd reaction flair gated on CHA; sponsor contracts reference style beyond kills/rounds.
- **Defensive stance / parry** - Bonus action for a defensive posture (damage reduction, counter, or disadvantage on next incoming attack).
- **Enemy formation + specials** - Distinct enemy tactical profiles so arena layouts matter more.
- **Gladiator pixel sprites** - Move the `gladiators.png` TextureRect/AtlasTexture setup to a Sprite2D/AnimatedSprite2D pattern with clearer placeholder art and animation hooks.
- **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX. `assets/audio/` TBD.

---

## Done

- **Project scaffold + full loop** - Godot 4.6 project, GameState autoload, Menu -> Management -> SponsorSelect -> Battle -> Result -> Management playable loop *(e9a9f50 - 67a1d98)*
- **Save / Load + sponsor contracts** - save/load/continue flow; SponsorSelect with kills, style/rounds, target-priority contracts; battle result rewards/penalties
- **Tactical movement + action economy foundation** - isometric grid, movement/action/bonus state, clickable moves, melee targeting, Shove, Execution Mark, Brutal Charge, Marksman, enemy advance AI
- **Style scoring display** - `_style_score` shown on all three contract types; crowd reaction log flair on Execution Mark kills
- **Pixel font** - m5x7 imported; applied globally via `assets/theme/bloodcorp.tres` (`gui/theme/custom`)
- **Gladiator stat block + D&D-style attack resolution** - STR/DEX/CON/INT/CHA, HP/DC formulas, d20 attacks, hit/miss/crit, flanking/mark advantage, melee/ranged damage dice
- **Data-driven skill refactor** - `SkillData.gd` defines Brutal Charge / Marksman / Execution Mark / Shove; `_build_units()` reads from it; unified `BtnBonus` + PopupMenu bonus-action UI
- **4th skill archetype + skill info UI** - Shield Bash bonus-action identity skill; HUD shows cost type label for all units
- **Arena planning feel** - grid expanded to 9x6; three arena layouts (blockers, hazards, spawns); path-aware BFS movement; hazard shoves deal 2 damage + STYLE +1
- **Design docs** - `GAME_DESIGN.md` (broad), `COMBAT_DESIGN.md` (battle), `TASKS.md` (backlog); churn direction, injury-over-death, hidden development arc, Service/Season clock, and Variance Principle locked in the decision log *(2026-06-02)*