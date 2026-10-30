extends Node
## Geopolitical Simulation (res://scripts/simulation/geopolitics.gd)
## Solves demographic expansion, trade arteries, and territorial sovereignty.

func simulate_demographics(cities: Array, world_grid: Node, pop_multiplier: float) -> void:
	for city in cities:
		if city["is_ruined"]:
			continue
		var growth_rate = 1.05 * pop_multiplier
		city["population"] = int(float(city["population"]) * growth_rate)
