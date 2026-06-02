class_name DevelopmentData

# ──────────────────────────────────────────────────────────────────────────────
# First-pass arc constants — all tunable for playtesting without touching logic.
# Careers span ~15–30 matches; peak is somewhere in the middle.
# ──────────────────────────────────────────────────────────────────────────────

const STAT_KEYS: Array = [
	"strength_score", "dexterity", "constitution", "intelligence", "charisma"
]
const SEASON_LENGTH: int = 5  # matches per Season (informational; used by future UI)

# Career stage thresholds relative to arc_peak_match.
const _RISING_ONSET: int  = 4   # Prospect until (peak - this) matches
const _PRIME_WINDOW: int  = 5   # Prime lasts this many matches after peak
const _DECLINE_WINDOW: int = 8  # Decline lasts this many matches before Spent

# Growth probability per stage (chance each stat gets +1 toward its ceiling).
const GROWTH_CHANCE_PROSPECT: float = 0.50
const GROWTH_CHANCE_RISING: float   = 0.70

# Erosion probability per development tick while in Decline (one random stat −1).
const DECLINE_EROSION_CHANCE: float = 0.35

# Minimum stat floor — erosion never goes below this.
const STAT_FLOOR: int = 3

# ──────────────────────────────────────────────────────────────────────────────
# Static helpers
# ──────────────────────────────────────────────────────────────────────────────

# Returns career stage string for a given service count and personal peak match.
static func stage_for(service: int, arc_peak_match: int) -> String:
	if service < arc_peak_match - _RISING_ONSET:
		return "Prospect"
	if service < arc_peak_match:
		return "Rising"
	if service < arc_peak_match + _PRIME_WINDOW:
		return "Prime"
	if service < arc_peak_match + _PRIME_WINDOW + _DECLINE_WINDOW:
		return "Decline"
	return "Spent"


# Rolls the hidden ceiling for a single stat.
# Loose upward bias: good recruits are probably good, but busts and steals exist.
# Result is always >= current_stat and <= 20.
static func roll_ceiling(current_stat: int) -> int:
	return clampi(current_stat + randi_range(-2, 6), current_stat, 20)


# Rolls the hidden match at which a gladiator enters Prime.
static func roll_arc_peak() -> int:
	return randi_range(10, 18)


# Growth chance for the given stage (0.0 means no growth).
static func growth_chance_for_stage(stage: String) -> float:
	match stage:
		"Prospect": return GROWTH_CHANCE_PROSPECT
		"Rising":   return GROWTH_CHANCE_RISING
		_:          return 0.0


# Maps a hidden ceiling dict to a fuzzy player-visible letter grade (D/C/B/A/S).
# Averages per-stat caps, buckets into a grade, then applies ±1 noise so the
# projection is an informed estimate rather than an exact readout.
# Roll once and store the result — never re-roll on display.
static func compute_projection_grade(ceiling: Dictionary) -> String:
	var grades := ["D", "C", "B", "A", "S"]
	var total := 0
	for stat in STAT_KEYS:
		total += int(ceiling.get(stat, 10))
	var avg: float = float(total) / float(STAT_KEYS.size())
	var idx := 0
	if avg >= 17.0:   idx = 4
	elif avg >= 14.0: idx = 3
	elif avg >= 11.0: idx = 2
	elif avg >= 8.0:  idx = 1
	return grades[clampi(idx + randi_range(-1, 1), 0, 4)]
