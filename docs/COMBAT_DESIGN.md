# Combat Design Direction

Bloodcorp's arena battles should grow into a compact tactical combat system inspired by Arena 8-style fights and cRPG movement patterns like Baldur's Gate 3. The goal is not to copy either reference directly, but to capture the feeling of gladiators making sharp positional choices inside a brutal corporate arena.

## Core Pillars

- **Compact tactical arenas:** Battles happen on readable isometric arenas with enough room for flanking, blocking, retreating, and pushing enemies into danger.
- **cRPG-style movement:** Gladiators can move a limited distance on their turn instead of being locked into static auto-battle positions.
- **Action economy:** Each active gladiator should eventually have a main action and a bonus action, making each turn a small tactical puzzle.
- **Character identity:** Every gladiator should feel different through class-like skills, cyberware, injuries, traits, and equipment.
- **Readable spectacle:** Turns should remain fast, clear, and violent, with sponsor objectives and crowd appeal shaping what the player values.

## Turn Structure

Each active gladiator should eventually support:

- **Movement:** Reposition within a limited range on the grid.
- **Main action:** Attack, use a major skill, interact with an arena object, or take a defensive stance.
- **Bonus action:** Use a smaller skill, quick item, shove, stance swap, cyberware trigger, or weapon-specific trick.
- **End turn:** Commit the chosen actions and move initiative forward.

The current speed-sorted initiative system can remain as the foundation. The first implementation slice should add player-readable choices without rewriting the whole battle loop.

## Skills

Skills should be tied to gladiator identity and equipment. Examples:

- **Brutal Charge:** Move in a straight line and strike the first enemy reached.
- **Execution Mark:** Bonus action that marks a wounded target for sponsor-favored kills.
- **Overclocked Reflexes:** Cyberware skill that grants extra movement or a dodge bonus.
- **Shield Bash:** Push an adjacent enemy and deal low damage.
- **Adrenal Inject:** Bonus action that restores a small amount of health but risks later injury.

Skills should define:

- Display name and short description.
- Main action or bonus action cost.
- Target rules.
- Range or movement rules.
- Cooldown or per-battle limit where needed.
- Sponsor/style tags where useful.

## Equipment

Equipment should do more than change stats over time. Weapons, armor, and cyberware can grant active or passive combat options.

- **Weapons:** Define base damage, range, and at least one tactical identity hook.
- **Armor:** Modify survivability, movement, initiative, or defensive actions.
- **Cyberware:** Add unusual skills, sponsor appeal, and risk/reward effects.

Management should show what a gladiator can do before deployment. Battle should surface granted skills clearly when that gladiator is active.

## First Implementation Target

A safe first slice would be:

1. Add a simple movement range to the active unit.
2. Let the player choose between movement and one basic attack.
3. Reserve data fields for main action, bonus action, and future skills.
4. Keep enemy AI simple: move toward the closest target, then attack if in range.

This preserves the existing loop while opening the door for tactical depth.
