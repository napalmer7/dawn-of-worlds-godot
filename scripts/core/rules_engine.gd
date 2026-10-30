extends Node
## Canonical Rules Engine (res://scripts/core/rules_engine.gd)
## Enforces official Dawn of Worlds Table of Powers costs, Thrift bonus math, and 2d6 rolling.

const TABLE_OF_POWERS = {
	"shape_land": {
		"name": "Shape Climate / Land",
		"cost": { 1: 5, 2: 6, 3: 8 },
		"min_age": 1,
		"description": "Raise mountains, sink oceans, shape plains, forests, volcanic crags, or tundra."
	},
	"create_race": {
		"name": "Create Sentient Race",
		"cost": { 1: 999, 2: 6, 3: 8 },
		"min_age": 2,
		"description": "Synthesize a new intelligent species with cradle sanctuary city & coat of arms."
	},
	"create_subrace": {
		"name": "Create Subrace / Evolve",
		"cost": { 1: 999, 2: 6, 3: 8 },
		"min_age": 2,
		"description": "Adapt an existing species in-place or birth a divergent splinter realm."
	},
	"curse_race": {
		"name": "Curse / Corrupt Race",
		"cost": { 1: 999, 2: 6, 3: 6 },
		"min_age": 2,
		"description": "Malevolent divine curse corrupting an entire race or splintering an evil cult realm."
	},
	"command_race": {
		"name": "Command Race",
		"cost": { 1: 999, 2: 4, 3: 6 },
		"min_age": 2,
		"description": "Direct a race to build a new colony settlement, expanding realm boundaries."
	},
	"advance_race": {
		"name": "Advance Race / City",
		"cost": { 1: 999, 2: 8, 3: 6 },
		"min_age": 2,
		"description": "Impart unique cultural crafts, architectural mastery, or fertility."
	},
	"advance_civ": {
		"name": "Advance Civ (Tech)",
		"cost": { 1: 999, 2: 6, 3: 4 },
		"min_age": 2,
		"description": "Research advancements across 5 tiers (Martial, Agri, Knowledge, Magic, Naval)."
	},
	"command_city": {
		"name": "Command City (Army)",
		"cost": { 1: 999, 2: 4, 3: 3 },
		"min_age": 2,
		"description": "Mobilize a grand army host from a city garrison to march or defend."
	},
	"create_order": {
		"name": "Create Holy / Arcane Order",
		"cost": { 1: 999, 2: 6, 3: 4 },
		"min_age": 2,
		"description": "Establish a chivalric chapter, mage cabal, druid circle, or syndicate."
	},
	"command_order": {
		"name": "Command Order",
		"cost": { 1: 999, 2: 3, 3: 2 },
		"min_age": 2,
		"description": "Dispatch orders on sanctified crusades or intelligence maneuvers."
	},
	"purify_civ": {
		"name": "Purify Civ (+1 Align)",
		"cost": { 1: 4, 2: 3, 3: 3 },
		"min_age": 1,
		"description": "Shift an empire's alignment toward Sacred Virtue (+1 Good)."
	},
	"corrupt_civ": {
		"name": "Corrupt Civ (-1 Align)",
		"cost": { 1: 3, 2: 2, 3: 2 },
		"min_age": 1,
		"description": "Lure an empire toward Abyssal Ambition (-1 Evil)."
	},
	"catastrophe": {
		"name": "Apocalyptic Catastrophe",
		"cost": { 1: 10, 2: 10, 3: 10 },
		"min_age": 1,
		"description": "Unleash Meteor, Supervolcano, Deluge, or Wildfire across 3.8 radial zone."
	},
	"custom_miracle": {
		"name": "Weave Custom Miracle",
		"cost": { 1: 5, 2: 5, 3: 5 },
		"min_age": 1,
		"description": "Player-engineered divine miracle altering climate, fertility, aura, or boons."
	},
	"create_avatar": {
		"name": "Create Divine Avatar",
		"cost": { 1: 10, 2: 7, 3: 8 },
		"min_age": 1,
		"description": "Manifest a towering demigod, celestial archon, or high wyrm on the map."
	},
	"command_avatar": {
		"name": "Command Avatar",
		"cost": { 1: 2, 2: 1, 3: 1 },
		"min_age": 1,
		"description": "Direct avatar to lead hosts in battle or execute divine miracles at zero cost."
	}
}

func get_power_cost(action_key: String, age: int) -> int:
	if not TABLE_OF_POWERS.has(action_key):
		push_error("Unknown power action key: " + action_key)
		return 999
	var def = TABLE_OF_POWERS[action_key]
	if age < def["min_age"]:
		return 999
	return def["cost"].get(age, 999)

func roll_2d6() -> Dictionary:
	var d1 = randi_range(1, 6)
	var d2 = randi_range(1, 6)
	return { "d1": d1, "d2": d2, "total": d1 + d2 }

func calculate_power_gain(thrift_bonus: int) -> Dictionary:
	var dice = roll_2d6()
	return {
		"dice": dice,
		"thrift": thrift_bonus,
		"total_gained": dice["total"] + thrift_bonus
	}

func calculate_new_thrift(remaining_power: int, current_thrift: int) -> int:
	if remaining_power <= 5:
		return mini(current_thrift + 1, 3)
	else:
		return 0
