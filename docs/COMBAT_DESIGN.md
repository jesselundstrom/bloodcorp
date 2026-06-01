# Combat Design Direction

Bloodcorp's arena battles should grow into a compact tactical combat system inspired by Arena 8-style fights and cRPG movement patterns like Baldur's Gate 3. The goal is not to copy either reference directly, but to capture the feeling of gladiators making sharp positional choices inside a brutal corporate arena.

## Core Pillars

- **Compact tactical arenas:** Battles happen on readable isometric arenas with enough room for flanking, blocking, retreating, and pushing enemies into danger.
- **cRPG-style movement:** Gladiators can move a limited distance on their turn instead of being locked into static auto-battle positions.
- **Action economy:** Each active gladiator has a main action and a bonus action, making each turn a small tactical puzzle.
- **Character identity:** Every gladiator should feel different through class-like skills, cyberware, injuries, traits, and equipment — and through distinct stat blocks that change how attack and damage rolls play out.
- **Readable spectacle:** Turns should remain fast, clear, and violent, with sponsor objectives and crowd appeal shaping what the player values.

## Current Battle Foundation *(implemented)*

The tactical combat foundation is live in `scripts/Battle.gd`:

- Arena grid is 7x5, with bounded left/right deployment so units never spawn outside the grid.
- Player turns show clickable highlighted movement tiles for reachable empty spaces.
- Units have `move_range`, `attack_range`, `has_moved`, `has_main_action`, and `has_bonus_action` fields — all reset each turn.
- Movement is once per turn; basic attacks consume the main action and require melee range (attack_range 1).
- Enemy AI moves toward the nearest living player and attacks if it reaches melee range.
- Sponsor objectives, kill tracking, target mark highlighting, and result rewards/penalties are all wired into battle flow.
- Action bar shows MOVE / ACTION / BONUS state per unit.
- Style score (`_style_score`) is displayed on all three contract types; Execution Mark kills trigger `★ THE CROWD ROARS! ★` log flair.
- **Attack resolution:** `1d20 + attack_bonus vs target.defense_class`. Miss = no damage. Hit = `weapon_die + stat_mod` (min 1). Crit (nat 20) = double dice. Proficiency +2 (recruit; +3 veteran / +4 champion deferred to rank system). Melee: 1d6 + STR_mod. Ranged (Marksman): 1d8 + DEX_mod. Flanking or Execution Mark → advantage (2d20 take high, binary — does not stack).
- **Current HP formula:** `max_hp = 8 + CON_mod`.

Three character skills are live: Brutal Charge (main action), Marksman (passive range upgrade), Execution Mark (bonus action). Skills are defined in `scripts/SkillData.gd` and assigned in `_build_units()` via a fallback index array — forward-compatible with a per-gladiator `skill` field in GameState once the roster system expands. Bonus actions (Shove + skill bonus actions) are surfaced via a single BtnBonus button that opens a PopupMenu.

## Turn Structure

Each active gladiator supports:

- **Movement:** Reposition within a limited range on the grid.
- **Main action:** Attack, use a major skill, interact with an arena object, or take a defensive stance.
- **Bonus action:** Use a smaller skill, quick item, shove, stance swap, cyberware trigger, or weapon-specific trick.
- **End turn:** Commit the chosen actions and move initiative forward.

The speed-sorted initiative system is the live foundation. Bonus action selection UI uses a single BtnBonus button that opens a PopupMenu listing available bonus actions (skill-specific and Shove), driven by `_available_bonus_actions()`.

## D&D-Style Hit/Miss/Damage Resolution *(implemented)*

The legacy `STR - ARM` formula is a placeholder. The intended system uses dice rolls and gladiator stat blocks, similar to D&D 5e but tuned for a fast gladiator game.

### Gladiator Stat Block

Each gladiator has five core stats. Stats start in the range 8–18 and change via leveling, equipment, and cyberware:

| Stat | Abbrev | Drives |
|------|--------|--------|
| Strength | STR | Melee attack rolls and melee damage |
| Dexterity | DEX | Ranged attack rolls, ranged damage, Defense Class, initiative |
| Constitution | CON | Max HP |
| Intelligence | INT | Tech/cyberware skill rolls |
| Charisma | CHA | Style score modifier, crowd reaction |

**Stat modifier formula** (classic D&D): `mod = floor((stat - 10) / 2)`. A stat of 10 gives +0, 14 gives +2, 8 gives -1.

### HP

`max_hp = 8 + CON_mod` per gladiator (flat; no per-level scaling yet). Replaces the `20 + armor * 2` placeholder once the stat block is wired in.

### Defense Class (DC)

Replaces flat armor subtraction. `DC = 10 + DEX_mod + armor_bonus`. Heavy armor grants a larger `armor_bonus` but may impose a DEX_mod cap. A naked gladiator with DEX 10 has DC 10.

### Attack Roll

`attack_roll = 1d20 + attack_bonus`  
- Melee attack bonus = STR_mod + proficiency  
- Ranged attack bonus = DEX_mod + proficiency  
- Finesse weapons (knives, blades) = max(STR_mod, DEX_mod)  
- Tech/cyberware skills = INT_mod + proficiency  

**Hit condition:** `attack_roll >= target.DC`  
**Miss:** no damage, no effect.  
**Critical hit:** natural 20 (the die shows 20 before bonuses) — doubles the number of damage dice rolled.

### Damage Roll

`damage = weapon_damage_dice + stat_mod`  
- Example: a short sword deals `1d6 + STR_mod`.  
- On a crit: `2d6 + STR_mod`.

### Flanking → Advantage

Flanking grants **advantage** on the attack roll: roll 2d20 and take the higher result. Replaces the flat `FLANK_BONUS (3)`.

### Execution Mark → Vulnerability

A marked target gives the attacker **advantage** on attack rolls against it. Replaces the flat `MARK_BONUS (2)`.

### Proficiency

Simple flat bonus scaling with gladiator tier: +2 (recruit), +3 (veteran), +4 (champion). Tied to level/rank, not individual skill points.

### Style / CHA Hook

`CHA_mod` adds directly to the style score earned per kill or spectacular action. Crowd reactions (log flair) can be gated on a CHA threshold.

## Skills

Skills are tied to gladiator identity and stat blocks. Examples:

- **Brutal Charge:** Move in a straight line and strike the first enemy reached. Uses STR attack roll.
- **Execution Mark:** Bonus action — marks a wounded target, granting the attacker advantage on all rolls against it this battle.
- **Overclocked Reflexes:** Cyberware skill — grants extra movement or imposes disadvantage on the next attack against this unit. Uses INT.
- **Shield Bash:** Push an adjacent enemy and deal low damage. STR attack roll; on hit, forced move 1 tile.
- **Adrenal Inject:** Bonus action — restores a small amount of HP but may impose a penalty die on CON-adjacent rolls later.

Skills define:

- Display name and short description.
- Main action or bonus action cost.
- Target rules.
- Range or movement rules.
- Which stat drives the attack roll (if any).
- Cooldown or per-battle limit where needed.
- Sponsor/style tags where useful.

## Equipment

Equipment does more than change stats. Weapons, armor, and cyberware grant active or passive combat options.

- **Weapons:** Define damage dice, range, attack stat (STR/DEX/finesse), and at least one tactical identity hook.
- **Armor:** Set `armor_bonus` for DC; may cap DEX_mod contribution; may modify initiative.
- **Cyberware:** Add unusual skills, sponsor appeal, INT-driven effects, and risk/reward mechanics.

Management should show what a gladiator can do before deployment. Battle surfaces granted skills clearly when that gladiator is active.

## Next Implementation Targets

1. **4th skill archetype + skill info UI** *(active — see TASKS.md Now)*: new archetype using the data model; skill names, costs, and cooldowns shown in battle UI per unit.
3. **Rank / tier system**: gladiator rank (recruit/veteran/champion) unlocks proficiency +3/+4 and stat progression; prerequisite for equipment system.
4. **Terrain / obstacle tiles**: block movement, create stronger positioning choices.
5. **Crowd/style scoring hooks via CHA**: sponsors can reference style beyond kills, rounds, and marked targets.
