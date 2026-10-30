extends Node
## Spontaneous Monstrous Race Emergence (res://scripts/simulation/monstrous_races.gd)
## In Age 2, rolls 10% default chance per round to spawn Goblins, Orcs, Kobolds, Dragons, Troglodytes.

const MONSTER_DEFINITIONS = {
	"goblins": { "name": "Goblins", "biomes": ["mountains", "hills", "forest"], "bonus": 0 },
	"orcs": { "name": "Blood-Sworn Orcs", "biomes": ["mountains", "plains", "hills"], "bonus": 1 },
	"kobolds": { "name": "Kobold Miners", "biomes": ["mountains", "volcanic"], "bonus": 0 },
	"dragons": { "name": "Wyrm Brood", "biomes": ["volcanic", "mountains", "tundra"], "bonus": 3 },
	"troglodytes": { "name": "Troglodyte Swarm", "biomes": ["swamp"], "bonus": 1 }
}

func roll_monstrous_emergence(age: int, spawn_chance_percent: float, world_grid: Node) -> Dictionary:
	if age != 2 or randf() * 100.0 > spawn_chance_percent:
		return {}

	var monster_keys = MONSTER_DEFINITIONS.keys()
	var chosen_key = monster_keys[randi() % monster_keys.size()]
	var def = MONSTER_DEFINITIONS[chosen_key]

	# Find valid biome cell
	var candidates: Array[Dictionary] = []
	for cell in world_grid.cells:
		if cell["terrain"] in def["biomes"] and cell["city_id"] == "":
			candidates.append(cell)

	if candidates.is_empty():
		return {}

	var target_cell = candidates[randi() % candidates.size()]
	var race_data = {
		"id": "monstrous_" + str(randi()),
		"name": def["name"],
		"military_bonus": def["bonus"],
		"spawn_cell_index": target_cell["index"]
	}

	EventBus.race_created.emit(race_data)
	return race_data
