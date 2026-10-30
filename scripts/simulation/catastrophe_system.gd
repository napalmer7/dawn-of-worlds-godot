extends Node
## Catastrophe System & Civilization Extinction (res://scripts/simulation/catastrophe_system.gd)
## Invariant: 3.8 radial blast zone. If zero active cities survive outside, civ collapses into extinction.

func unleash_catastrophe(epicenter_index: int, disaster_type: String, world_grid: Node, civs: Array) -> Dictionary:
	var affected_cells = world_grid.get_cells_in_radius(epicenter_index, 3.8)
	var epicenter = world_grid.cells[epicenter_index]

	var ruined_cities: Array[String] = []
	var damaged_civs: Dictionary = {}

	for cell in affected_cells:
		var dist = world_grid.get_cell_distance(epicenter, cell)
		match disaster_type:
			"meteor":
				if dist < 1.0:
					cell["elevation"] = -0.5
					cell["terrain"] = "volcanic"
			"supervolcano":
				if dist < 1.0:
					cell["terrain"] = "volcanic"
					cell["elevation"] = 0.85
			"deluge":
				cell["elevation"] = minf(cell["elevation"], -0.1)
				cell["terrain"] = "shallow_water"

		if cell.get("city_id", "") != "":
			var city_id = cell["city_id"]
			var civ_id = cell["civ_id"]
			damaged_civs[civ_id] = true

			if dist < 2.0:
				cell["population"] = int(cell["population"] * 0.1)
				ruined_cities.append(city_id)
			else:
				cell["population"] = int(cell["population"] * 0.3)

	var extinguished_civs: Array[String] = []
	for civ_id in damaged_civs.keys():
		var surviving_active_cities = count_surviving_cities_outside(civ_id, affected_cells, world_grid)
		if surviving_active_cities == 0:
			extinguished_civs.append(civ_id)
			EventBus.civilization_extinguished.emit(civ_id, "Extinction by " + disaster_type.capitalize())

	EventBus.catastrophe_unleashed.emit(epicenter_index, disaster_type, ruined_cities)
	return {
		"ruined_cities": ruined_cities,
		"extinguished_civs": extinguished_civs
	}

func count_surviving_cities_outside(civ_id: String, affected_cells: Array, world_grid: Node) -> int:
	var count = 0
	for cell in world_grid.cells:
		if cell.get("civ_id", "") == civ_id and cell.get("city_id", "") != "":
			if not cell in affected_cells and cell["population"] > 0:
				count += 1
	return count
