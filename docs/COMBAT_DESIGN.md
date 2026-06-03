# Combat Design Direction

Bloodcorp's arena battles should grow into a compact tactical combat system inspired by Arena 8-style fights and cRPG movement patterns like Baldur's Gate 3. The goal is not to copy either reference directly, but to capture the feeling of gladiators making sharp positional choices inside a brutal corporate arena.

Combat exists to serve a **churn-focused** roster game (see `docs/GAME_DESIGN.md`). Two consequences shape everything here: per-gladiator depth is moderate, and **death is rare while injury is common** — combat variance must produce recoverable setbacks, not the loss of an invested asset to a single roll.

## Core Pillars

- **Compact tactical arenas:** Battles happen on readable isometric arenas with enough room for flanking, blocking, retreating, and pushing enemies into danger.
- **cRPG-style movement:** Gladiators can move a limited distance on their turn instead of being locked into static auto-battle positions.
- **Action economy:** Each active gladiator has a main action and a bonus action, making each turn a small tactical puzzle.
- **Character identity:** Every gladiator should feel different through class-like skills, cyberware, injuries, traits, and equipment, and through distinct stat blocks that change how attack and damage rolls play out.
- **Readable spectacle:** Turns should remain fast, clear, and violent, with sponsor objectives and crowd appeal shaping what the player values.
- **Setbacks over catastrophes:** A lost exchange should usually mean an injury, not a death. See "Casualty Resolution".

## Current Battle Foundation *(implemented)*

The tactical combat foundation is live in `scripts/Battle.gd`:

- Arena grid is 9x6.
- Each battle selects one of three local arena layouts with named blockers, hazards, player spawns, and enemy spawns.
- Player turns show clickable highlighted movement tiles for reachable empty spaces.
- Movement uses path-aware BFS, so blockers and occupied units shape actual routes instead of only Manhattan distance.
- Blockers are impassable and stop Brutal Charge.
- Hazards are walkable in v1; forced movement into a hazard deals 2 damage and grants STYLE +1 against enemies.
- Units have `move_range`, `attack_range`, `has_moved`, `has_main_action`, and `has_bonus_action` fields, all reset each turn.
- Movement is once per turn; basic attacks consume the main action and require melee range unless a passive changes range.
- Enemy AI advances toward the nearest living player using reachable movement tiles, then attacks if in range.
- Sponsor objectives, kill tracking, target mark highlighting, style score, and result rewards/penalties are wired into battle flow.
- Bonus actions use a single `BtnBonus` button and PopupMenu listing available actions.
- Battle presentation uses contextual isometric diamond highlights instead of rectangular boxes, tweened path movement for player/enemy moves plus shoves/charges, foot-ring selection states, hit/miss/damage floaters, and downed/eliminated fade-outs. These are presentation hooks only; combat rules and save data are unchanged.
- Unit presentation is routed through a runtime `BattleUnitVisual` wrapper (`visual_root`, shadow, ring, sprite, status marker, floating HP bar). Normalized 6x6 animation sheets live under `assets/sprites/gladiators/` for Brutal Charge, Marksman, Execution Mark, Shield Bash, and enemy bruisers; the old `assets/sprites/gladiators.png` atlas remains the fallback if a sheet is missing or malformed. Idle presentation is intentionally quiet but alive: units hold a stable stance frame with a tiny vertical pulse, while the active unit gets a stronger procedural bob.
- Arena presentation uses reusable drawn `BattleIsoTile` variants for move/attack highlights, raised blocker diamonds, and pulsing hazard diamonds over a generated raster broadcast-arena background. A bounded board projection keeps the 9x6 playable field inside the painted floor, while a light `BattleArenaFloor` overlay adds faint grid/marking accents. The battle HUD uses raised on-unit HP bars, a compact top scorebug, a bottom command deck, and a ticker-style combat log so status no longer lives in full-height side rails. `BattleCombatEffect` owns transient melee impact, ranged streak, and crit feedback.
- **Attack resolution:** `1d20 + attack_bonus vs target.defense_class`. Miss = no damage. Hit = `weapon_die + stat_mod` (min 1). Crit (nat 20) = double dice. Proficiency +2 for recruits. Melee: 1d6 + STR_mod. Ranged (Marksman): 1d8 + DEX_mod. Flanking or Execution Mark grants advantage.
- **Current HP formula:** `max_hp = 8 + CON_mod`.

Character skills are data-driven in `scripts/SkillData.gd`: Brutal Charge, Marksman, Execution Mark, and Shield Bash. Skills are assigned in `_build_units()` via a fallback index array, forward-compatible with a per-gladiator `skill` field once the roster system expands.

## Turn Structure

Each active gladiator supports:

- **Movement:** Reposition within a limited range on the grid.
- **Main action:** Attack, use a major skill, interact with an arena object, or take a defensive stance.
- **Bonus action:** Use a smaller skill, shove, quick item, stance swap, cyberware trigger, or weapon-specific trick.
- **End turn:** Commit the chosen actions and move initiative forward.

The speed-sorted initiative system is the live foundation. Bonus action selection UI uses a single `BtnBonus` button that opens a PopupMenu listing available bonus actions, driven by `_available_bonus_actions()`.

## D&D-Style Hit/Miss/Damage Resolution *(implemented)*

The current combat resolution uses dice rolls and gladiator stat blocks, similar to D&D 5e but tuned for a fast gladiator game.

| Stat | Abbrev | Drives |
|------|--------|--------|
| Strength | STR | Melee attack rolls and melee damage |
| Dexterity | DEX | Ranged attack rolls, ranged damage, Defense Class, initiative |
| Constitution | CON | Max HP |
| Intelligence | INT | Tech/cyberware skill rolls |
| Charisma | CHA | Style score modifier, crowd reaction |

`mod = floor((stat - 10) / 2)`.

- `max_hp = 8 + CON_mod`
- `DC = 10 + DEX_mod + armor_bonus`
- Melee attack bonus = STR_mod + proficiency
- Ranged attack bonus = DEX_mod + proficiency
- Finesse weapons will use max(STR_mod, DEX_mod)
- Tech/cyberware skills will use INT_mod + proficiency
- Crits double damage dice
- Flanking and Execution Mark grant advantage; they do not stack

### Variance & the Churn Game

The d20 is intentionally swingy, which is fine *because* downed gladiators usually survive (see Casualty Resolution). The dice are paired with player control through positioning, action economy, and target choice — never let a high-variance outcome land without a decision the player could have made differently.

## Casualty Resolution *(implemented)*

When a unit reaches 0 HP it is **downed**, not instantly killed.

- A **downed** unit is removed from the current battle (out of the fight) but is not yet dead.
- **Enemies** are disposable NPCs: a downed enemy is killed for objective/kill-count purposes (no change from old behavior).
- **Player gladiators** survive to a post-battle **casualty roll** resolved in `_resolve_casualties()` (Battle.gd):
  - d10 roll: **1** = death (permanent roster removal), **2–4** = serious injury, **5–10** = minor injury.
  - Stage modifiers are **deferred** — the flat d10 is the first-pass roll. When the career-stage system lands, stage will shift these odds.
  - "Last contract" gamble (deliberate death odds shift) is also deferred.
- Casualty report lines are logged to the combat log and visible on the result overlay.

### Injuries *(implemented)*

Injuries are data-driven in `scripts/InjuryData.gd`, apply stat/HP penalties, and recover over a number of matches (or instantly via med bay — deferred).

| Injury | Effect | Recovery |
|--------|--------|----------|
| Broken Arm | -2 STR (`strength_score`) | 3 matches |
| Damaged Optic | -2 DEX (`dexterity`) | 3 matches |
| Cracked Plating | -1 CON (`constitution`), -10% effective HP | 3 matches |

- Penalties are applied in `_build_units()` before `hp_max`/`defense_class` are derived; `hp_max` floors at 1.
- `GameState.MAX_INJURIES = 3` caps concurrent injuries; exceeding it silently clamps (spike to death chance is a TODO for the stage system).
- `GameState.tick_injuries()` decrements recovery counters once per battle (runs in `_show_result` after casualty resolution, before `save_game`).
- Management roster cards show active injuries with remaining match count in amber.
- `GameState.heal_injury_immediate()` stub reserves the med-bay API; no UI yet.
- Carrying injuries into a fight is a player choice — this is the decision paired with the injury RNG.

## Development Arc Hooks *(planned)*

Combat is the engine that drives the Service clock and development arc:

- **Each battle advances Service** for participating gladiators (`+1 match`, plus combat events such as kills feeding XP/development).
- **Development ticks** resolve after battle (in management/result flow), rolling stat increases toward the hidden Ceiling per the current stage. Combat only *feeds* this; it does not own the arc logic.
- **Decline stage** is reflected in the stat block (eroded stats) and the casualty roll (higher risk), so a fading gladiator visibly performs worse in the arena.

## Skills

Skills define display name, description, action cost, target rules, range or movement rules, attack stat, cooldown/per-battle limit, and future sponsor/style tags.

Implemented examples:

- **Brutal Charge:** Main action. Move in a straight line and strike the first enemy reached. Uses STR attack roll.
- **Marksman:** Passive. Ranged attacks at distance 2 using DEX.
- **Execution Mark:** Bonus action. Mark a wounded adjacent enemy, granting advantage against it this battle.
- **Shield Bash:** Bonus action. Deal 2 damage to an adjacent enemy. It does not push in the current slice.
- **Shove:** Universal bonus action. Push an adjacent enemy, slam them into an obstruction, or force them into a hazard.

Future examples:

- **Overclocked Reflexes:** Cyberware skill that grants extra movement or imposes disadvantage on the next attack against this unit. Uses INT.
- **Adrenal Inject:** Bonus action that restores a small amount of HP with a later drawback.

## Equipment

Equipment does more than change stats. Weapons, armor, and cyberware grant active or passive combat options.

- **Weapons:** Define damage dice, range, attack stat (STR/DEX/finesse), and at least one tactical identity hook.
- **Armor:** Set `armor_bonus` for DC; may cap DEX_mod contribution; may modify initiative.
- **Cyberware:** Add unusual skills, sponsor appeal, INT-driven effects, and risk/reward mechanics.

Management should show what a gladiator can do before deployment. Battle surfaces granted skills clearly when that gladiator is active.

## Next Implementation Targets

1. **Casualty Resolution + injuries:** down-instead-of-die, post-battle casualty roll, injury data model, med bay recovery. Foundational to the churn feel and de-risks combat variance.
2. **Service clock + development ticks:** per-match Service counter and a post-battle development tick that grows stats toward a hidden Ceiling.
3. **Rank / tier system:** recruit/veteran/champion unlocks proficiency +3/+4 and stat progression; prerequisite for the equipment system.
4. **Decline-stage combat effects:** stat erosion and elevated casualty risk for fading gladiators.
5. **Enemy formation and specials:** distinct enemy tactical profiles so arena layouts matter more.
6. **Crowd/style scoring hooks via CHA:** sponsors can reference style beyond kills, rounds, and marked targets.
7. **Equipment / weapon shop:** weapons and armor grant active and passive combat options.
