# Bloodcorp - Task List

<!-- Agent instructions: Update Now/Next/Later as work completes.
     Move finished items to Done. Summarise batches of >=3 related Done items into one line.
     Keep Done to <=10 lines total - compress oldest entries first.
     Only one item belongs in Now at a time.
     Mark sub-tasks [x] when done, [ ] when planned but not yet done. -->

---

## Now

- **Scouting** - Credit-spend in Management to narrow the Projection band (requires Comms Suite facility). Deferred until Facility Upgrades exist.

## Later

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
- **Audio** - AudioStreamPlayer manager autoload, looping menu music, attack/death SFX. `assets/audio/` TBD.

---

## Done

- **Playable loop + early presentation** - Godot 4.6 project, GameState autoload, Menu -> Management -> SponsorSelect -> Battle -> Result -> Management, save/load/continue, sponsor contracts, style scoring display, and global m5x7 pixel font.
- **Tactical movement + action economy foundation** - isometric grid, movement/action/bonus state, clickable moves, melee targeting, Shove, Execution Mark, Brutal Charge, Marksman, enemy advance AI.
- **Gladiator stat block + D&D-style attack resolution** - STR/DEX/CON/INT/CHA, HP/DC formulas, d20 attacks, hit/miss/crit, flanking/mark advantage, melee/ranged damage dice
- **Data-driven skill/action UI foundation** - `SkillData.gd` defines Brutal Charge, Marksman, Execution Mark, Shield Bash, and Shove; `_build_units()` reads skill data; unified `BtnBonus` PopupMenu and HUD cost labels are live.
- **Arena Movement Overhaul v1** - grid expanded to configurable 13x9 with ellipse-masked valid tiles, tile metadata, rough/raised/high/ramp terrain, Speed-derived movement range, ramp-gated elevation pathing, context-only movement reticles, round-cycling Plasma Vents, shove previews, collision/fall/vent damage, lethal ring-outs, and cleaner lane-focused layouts. *(2026-06-03; ramp/free-feeling pass 2026-06-04)*
- **Arena battle polish + visual layer** - contextual floor indicators, tactical zoom/readability pass, faction base rings, active glow/pulse, hover/selected nameplates, quieter move/path/attack target presentation, wrapper-based unit visuals with stronger shadows/rings/status indicators/raised floating HP bars, normalized padded animation sheets with quiet idle, enemy bruiser scale/timing pass, generated broadcast arena background, bounded board projection, cleaner starting formations, broadcast scorebug pods, active-unit state chips, live-feed ticker, clearer command deck states, atlas fallback, tweened path movement, melee/ranged/crit feedback, floating damage/miss text, hit hold/bump feedback, and down fades. *(2026-06-02; HUD/bruiser polish 2026-06-03; readability pass 2026-06-03; clarity pass 2026-06-04)*
- **Design docs** - `GAME_DESIGN.md` (broad), `COMBAT_DESIGN.md` (battle), `TASKS.md` (backlog); churn direction, injury-over-death, hidden development arc, Service/Season clock, and Variance Principle locked in the decision log *(2026-06-02)*
- **Casualty Resolution + injuries** - 0 HP → downed (not dead) for player gladiators; enemies die as before. Post-battle d10 casualty roll: 1=death, 2-4=serious injury, 5-10=minor injury. `InjuryData.gd` defines three data-driven injuries (Broken Arm, Damaged Optic, Cracked Plating) with stat/HP penalties and 3-match recovery. Injuries show on roster cards in Management. *(2026-06-02)*
- **Service clock + development arc** - Per-gladiator `service` counter, hidden `ceiling`/`arc_peak_match`, and career stages (Prospect→Rising→Prime→Decline→Spent). Post-battle development tick in `Battle._resolve_development()` rolls stat growth (+1) or erosion (−1). Changes logged in result screen. Constants isolated in `DevelopmentData.gd` for playtest tuning. *(2026-06-02)*
- **Fuzzy Projection display** - `projection_grade` (D/C/B/A/S) computed once from hidden ceiling with ±1 fuzz, stored on gladiator dict, shown on all Management cards. Roster cards also show `career_stage`. Scouting (grade narrowing) deferred to Facility Upgrades. *(2026-06-02)*
