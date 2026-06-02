class_name InjuryData

const INJURIES: Dictionary = {
	"broken_arm": {
		"display_name": "Broken Arm",
		"stat_penalties": {"strength_score": -2},
		"hp_pct_penalty": 0.0,
		"recovery_matches": 3,
	},
	"damaged_optic": {
		"display_name": "Damaged Optic",
		"stat_penalties": {"dexterity": -2},
		"hp_pct_penalty": 0.0,
		"recovery_matches": 3,
	},
	"cracked_plating": {
		"display_name": "Cracked Plating",
		"stat_penalties": {"constitution": -1},
		"hp_pct_penalty": 0.10,
		"recovery_matches": 3,
	},
}

const _MINOR_POOL: Array = ["broken_arm", "damaged_optic", "cracked_plating"]
const _SERIOUS_POOL: Array = ["broken_arm", "damaged_optic", "cracked_plating"]

static func random_minor() -> String:
	return _MINOR_POOL[randi() % _MINOR_POOL.size()]

# Serious injuries use the same pool but with 2x recovery_matches applied by the caller.
static func random_serious() -> String:
	return _SERIOUS_POOL[randi() % _SERIOUS_POOL.size()]
