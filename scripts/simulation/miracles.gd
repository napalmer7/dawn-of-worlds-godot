extends Node
## Custom Miracle Weaving Engine (res://scripts/simulation/miracles.gd)
## Enchants world cells with divine auras altering fertility, moisture, or holy wards.

func weave_miracle(cell_index: int, miracle_type: String, duration_rounds: int, world_grid: Node) -> void:
	if cell_index < 0 or cell_index >= world_grid.cells.size():
		return
	var cell = world_grid.cells[cell_index]
	cell["miracle_aura"] = miracle_type
	match miracle_type:
		"blessing_of_abundance": cell["fertility"] = 1.0
		"leyline_conflux": cell["moisture"] = minf(cell["moisture"] + 0.4, 1.0)
		"holy_sanctuary": cell["defense_aura"] = 2
	EventBus.miracle_woven.emit(cell_index, miracle_type, duration_rounds)
