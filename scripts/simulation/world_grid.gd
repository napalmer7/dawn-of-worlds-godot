extends Node2D
## Spherical Fibonacci Lattice & Cascading Terrain (res://scripts/simulation/world_grid.gd)
## Models cell topography, 11 terrain classes, 2-stage ocean sinking, and climate cascades.

const TERRAIN_TYPES = {
	"deep_ocean": { "color": Color(0.06, 0.12, 0.28), "is_water": true },
	"ocean": { "color": Color(0.12, 0.25, 0.48), "is_water": true },
	"shallow_water": { "color": Color(0.24, 0.55, 0.72), "is_water": true },
	"plains": { "color": Color(0.42, 0.72, 0.32), "is_water": false },
	"forest": { "color": Color(0.18, 0.48, 0.22), "is_water": false },
	"hills": { "color": Color(0.58, 0.52, 0.32), "is_water": false },
	"mountains": { "color": Color(0.68, 0.65, 0.62), "is_water": false },
	"swamp": { "color": Color(0.32, 0.42, 0.28), "is_water": false },
	"desert": { "color": Color(0.85, 0.74, 0.42), "is_water": false },
	"tundra": { "color": Color(0.78, 0.86, 0.90), "is_water": false },
	"volcanic": { "color": Color(0.35, 0.18, 0.18), "is_water": false }
}

@export var cell_count: int = 250
var cells: Array[Dictionary] = []

func _ready() -> void:
	generate_fibonacci_lattice()

func generate_fibonacci_lattice() -> void:
	cells.clear()
	var phi = (1.0 + sqrt(5.0)) / 2.0 - 1.0
	for i in range(cell_count):
		var y = 1.0 - (float(i) / float(cell_count - 1)) * 2.0
		var radius = sqrt(max(0.0, 1.0 - y * y))
		var theta = phi * 2.0 * PI * float(i)
		var x = cos(theta) * radius
		var z = sin(theta) * radius

		var lat = asin(y) * (180.0 / PI)
		var lon = atan2(z, x) * (180.0 / PI)

		var elev = sin(x * 2.5) * cos(z * 2.5) + y * 0.2
		var terrain = "ocean"
		if elev > 0.4:
			terrain = "mountains"
		elif elev > 0.2:
			terrain = "hills"
		elif elev > 0.05:
			terrain = "forest" if randf() > 0.5 else "plains"
		elif elev > -0.2:
			terrain = "shallow_water"
		else:
			terrain = "deep_ocean"

		cells.append({
			"index": i,
			"lat": lat,
			"lon": lon,
			"pos3d": Vector3(x, y, z),
			"elevation": elev,
			"terrain": terrain,
			"fertility": clampf(0.5 + elev * 0.3, 0.0, 1.0),
			"city_id": "",
			"civ_id": "",
			"population": 0,
			"miracle_aura": ""
		})

func get_cell_distance(cell_a: Dictionary, cell_b: Dictionary) -> float:
	var p1: Vector3 = cell_a["pos3d"]
	var p2: Vector3 = cell_b["pos3d"]
	var dot_val = clampf(p1.dot(p2), -1.0, 1.0)
	var angle = acos(dot_val)
	return angle * (sqrt(float(cell_count)) / PI)

func get_cells_in_radius(center_index: int, max_radius: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if center_index < 0 or center_index >= cells.size():
		return result
	var center = cells[center_index]
	for c in cells:
		var dist = get_cell_distance(center, c)
		if dist <= max_radius:
			result.append(c)
	return result

func shape_terrain_cascade(center_index: int, target_terrain: String, scope: String) -> void:
	if center_index < 0 or center_index >= cells.size():
		return
	var center = cells[center_index]

	if scope == "pinpoint":
		apply_terrain_to_cell(center, target_terrain)
		EventBus.cell_terrain_shaped.emit(center["index"], center["terrain"], center["elevation"])
		return

	var radius = 2.0 if scope == "regional" else 3.8
	var affected = get_cells_in_radius(center_index, radius)

	for c in affected:
		var dist = get_cell_distance(center, c)
		if target_terrain == "sink_ocean":
			apply_sink_ocean(c, dist)
		elif target_terrain == "desert":
			apply_desert_cascade(c, dist)
		elif target_terrain == "tundra":
			apply_tundra_cascade(c, dist)
		else:
			if dist < 1.0:
				apply_terrain_to_cell(c, target_terrain)
			elif dist < 2.0 and randf() > 0.3:
				apply_terrain_to_cell(c, target_terrain)
		EventBus.cell_terrain_shaped.emit(c["index"], c["terrain"], c["elevation"])

func apply_sink_ocean(cell: Dictionary, dist: float) -> void:
	if dist < 1.0:
		cell["elevation"] = -0.85
		cell["terrain"] = "deep_ocean"
	elif dist < 2.2:
		cell["elevation"] = -0.45
		cell["terrain"] = "ocean"
	else:
		cell["elevation"] = maxf(-0.15, cell["elevation"] - 0.28)
		if cell["elevation"] <= 0.0:
			cell["terrain"] = "shallow_water"

func apply_desert_cascade(cell: Dictionary, dist: float) -> void:
	if dist < 1.5:
		if not TERRAIN_TYPES[cell["terrain"]]["is_water"]:
			cell["terrain"] = "desert"
	elif dist < 2.8:
		if cell["terrain"] == "forest":
			cell["terrain"] = "plains"

func apply_tundra_cascade(cell: Dictionary, dist: float) -> void:
	if cell["terrain"] != "mountains" and cell["terrain"] != "hills" and not TERRAIN_TYPES[cell["terrain"]]["is_water"]:
		cell["terrain"] = "tundra"

func apply_terrain_to_cell(cell: Dictionary, terrain_name: String) -> void:
	cell["terrain"] = terrain_name
	match terrain_name:
		"mountains": cell["elevation"] = maxf(cell["elevation"], 0.75)
		"hills": cell["elevation"] = clampf(cell["elevation"], 0.35, 0.65)
		"plains", "forest", "swamp": cell["elevation"] = clampf(cell["elevation"], 0.1, 0.4)
		"volcanic": cell["elevation"] = maxf(cell["elevation"], 0.6)
		"deep_ocean": cell["elevation"] = -0.75
		"ocean": cell["elevation"] = -0.35
		"shallow_water": cell["elevation"] = -0.05
