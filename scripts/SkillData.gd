class_name SkillData

# Per-gladiator identity skills. Keyed by skill_key string.
# attack_stat is forward-prep for 4th archetype; not wired into resolution this slice.
const SKILLS: Dictionary = {
	"brutal_charge": {
		"display_name": "Brutal Charge",
		"description": "Move in a straight line and strike the first enemy reached.",
		"action_cost": "main",
		"valid_targets": "enemy",
		"attack_stat": "strength",
		"cooldown": 0,
		"attack_range": 1,
	},
	"marksman": {
		"display_name": "Marksman",
		"description": "Ranged attacks at distance 2 using Dexterity.",
		"action_cost": "passive",
		"valid_targets": "none",
		"attack_stat": "dexterity",
		"cooldown": 0,
		"attack_range": 2,
	},
	"execution_mark": {
		"display_name": "Execution Mark",
		"description": "Mark a wounded adjacent enemy; gain advantage against it all battle.",
		"action_cost": "bonus",
		"valid_targets": "wounded_enemy",
		"attack_stat": "",
		"cooldown": 0,
		"attack_range": 1,
	},
	"shield_bash": {
		"display_name": "Shield Bash",
		"description": "Slam an adjacent enemy with your shield, dealing 2 damage.",
		"action_cost": "bonus",
		"valid_targets": "enemy",
		"attack_stat": "strength",
		"cooldown": 0,
		"attack_range": 1,
	},
}

# Universal bonus action available to every unit (not a gladiator identity skill).
const SHOVE: Dictionary = {
	"display_name": "Shove",
	"description": "Push an adjacent enemy back, into an impact, or into a hazard.",
	"action_cost": "bonus",
	"valid_targets": "enemy",
	"attack_stat": "",
}
