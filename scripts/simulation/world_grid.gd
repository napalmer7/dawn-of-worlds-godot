extends Node2D
## Spherical Fibonacci Lattice & Cascading Terrain (res://scripts/simulation/world_grid.gd)
## Renders the world map, 11 terrain classes, 2-stage ocean sinking, and handles cell interaction.

const TERRAIN_TYPES = {
	"deep_ocean": { "color": Color(0.06, 0.12, 0.28), "is_water": true },
	"ocean": { "color": Color(0.12, 0.25, 0.48), "is_water": true },
	"shallow_water": { "color": Color(0.24, 0.55, 0.72), "is_water": true },
	"plains": { "color": Color(0.35, 0.75, 0.32), "is_water": false },
	"forest": { "color": Color(0.12, 0.45, 0.18), "is_water": false },
	"hills": { "color": Color(0.62, 0.52, 0.30), "is_water": false },
	"mountains": { "color": Color(0.68, 0.70, 0.74), "is_water": false },
	"swamp": { "color": Color(0.28, 0.40, 0.22), "is_water": false },
	"desert": { "color": Color(0.88, 0.76, 0.38), "is_water": false },
	"tundra": { "color": Color(0.75, 0.88, 0.94), "is_water": false },
	"volcanic": { "color": Color(0.75, 0.20, 0.18), "is_water": false }
}

@export var cell_count: int = 250
var cells: Array[Dictionary] = []
var selected_cell_index: int = 0
var hovered_cell_index: int = -1

# Map Viewport Bounds (leaves right side for Powers Dock)
var map_origin: Vector2 = Vector2(24, 64)
var map_size: Vector2 = Vector2(940, 630)
var map_center: Vector2 = Vector2(494, 379)

func _ready() -> void:
	generate_fibonacci_lattice()
	if EventBus:
		EventBus.cell_terrain_shaped.connect(func(_idx, _t, _e): queue_redraw())
		EventBus.catastrophe_unleashed.connect(func(_idx, _t, _c): queue_redraw())
		EventBus.city_founded.connect(func(_d): queue_redraw())
	queue_redraw()
	# Emit initial selection
	if not cells.is_empty():
		call_deferred("select_cell", 0)

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

		# Screen projection coordinates
		var screen_x = map_center.x + (lon / 180.0) * (map_size.x * 0.47)
		var screen_y = map_center.y - (lat / 90.0) * (map_size.y * 0.45)
		var screen_pos = Vector2(screen_x, screen_y)

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
			"screen_pos": screen_pos,
			"elevation": elev,
			"terrain": terrain,
			"fertility": clampf(0.5 + elev * 0.3, 0.0, 1.0),
			"city_id": "",
			"city_name": "",
			"civ_id": "",
			"population": 0,
			"miracle_aura": ""
		})

func _draw() -> void:
	# 1. Cosmic Ocean Backdrop
	draw_rect(Rect2(map_origin, map_size), Color(0.04, 0.07, 0.14), true)
	draw_rect(Rect2(map_origin, map_size), Color(0.22, 0.35, 0.55, 0.6), false, 2.0)

	# 2. Celestial Coordinate Parallels & Meridians
	var grid_color = Color(0.2, 0.35, 0.55, 0.2)
	for lat_line in [-60, -30, 0, 30, 60]:
		var y_pos = map_center.y - (float(lat_line) / 90.0) * (map_size.y * 0.45)
		draw_line(Vector2(map_origin.x, y_pos), Vector2(map_origin.x + map_size.x, y_pos), grid_color, 1.0)
	for lon_line in [-120, -60, 0, 60, 120]:
		var x_pos = map_center.x + (float(lon_line) / 180.0) * (map_size.x * 0.47)
		draw_line(Vector2(x_pos, map_origin.y), Vector2(x_pos, map_origin.y + map_size.y), grid_color, 1.0)

	# 3. Draw All Coordinate Cells
	for cell in cells:
		var pos = cell["screen_pos"]
		var terrain_type = cell["terrain"]
		var color = TERRAIN_TYPES.get(terrain_type, TERRAIN_TYPES["ocean"])["color"]
		var radius = 13.0

		# Base Cell Tile
		draw_circle(pos, radius, color)
		draw_arc(pos, radius, 0, TAU, 16, color.darkened(0.3), 1.2)

		# Distinct Biome Glyphs
		match terrain_type:
			"mountains":
				# Snowcap peak triangle
				var pts = PackedVector2Array([pos + Vector2(0, -9), pos + Vector2(-6, 5), pos + Vector2(6, 5)])
				draw_colored_polygon(pts, Color(0.95, 0.98, 1.0))
			"volcanic":
				# Glowing magma center
				draw_circle(pos, 5.0, Color(1.0, 0.4, 0.1))
			"forest":
				# Canopy core
				draw_circle(pos, 4.0, Color(0.08, 0.28, 0.12))
			"desert":
				# Dune core
				draw_circle(pos, 3.5, Color(1.0, 0.88, 0.4))
			"tundra":
				# Glacial ice sheen
				draw_circle(pos, 4.0, Color(0.9, 0.96, 1.0))

		# Settlement Marker
		if cell.get("city_id", "") != "":
			draw_rect(Rect2(pos - Vector2(6, 6), Vector2(12, 12)), Color(1.0, 0.85, 0.1), true)
			draw_rect(Rect2(pos - Vector2(6, 6), Vector2(12, 12)), Color(0.1, 0.1, 0.1), false, 1.5)
			var font = ThemeDB.fallback_font
			if font:
				draw_string(font, pos + Vector2(8, -8), cell.get("city_name", "City"), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.95, 0.5))

		# Hover Outline
		if cell["index"] == hovered_cell_index and hovered_cell_index != selected_cell_index:
			draw_arc(pos, radius + 2.0, 0, TAU, 20, Color(1.0, 1.0, 1.0, 0.6), 1.5)

		# Selected Cell Reticle
		if cell["index"] == selected_cell_index:
			draw_arc(pos, radius + 4.0, 0, TAU, 24, Color(1.0, 0.85, 0.2, 0.95), 2.5)
			draw_line(pos + Vector2(-radius - 7, 0), pos + Vector2(-radius - 1, 0), Color(1.0, 0.85, 0.2), 2.0)
			draw_line(pos + Vector2(radius + 1, 0), pos + Vector2(radius + 7, 0), Color(1.0, 0.85, 0.2), 2.0)
			draw_line(pos + Vector2(0, -radius - 7), pos + Vector2(0, -radius - 1), Color(1.0, 0.85, 0.2), 2.0)
			draw_line(pos + Vector2(0, radius + 1), pos + Vector2(0, radius + 7), Color(1.0, 0.85, 0.2), 2.0)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		var closest = find_closest_cell(mouse_pos, 18.0)
		if closest != hovered_cell_index:
			hovered_cell_index = closest
			queue_redraw()

	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		var clicked = find_closest_cell(mouse_pos, 22.0)
		if clicked != -1:
			select_cell(clicked)

func find_closest_cell(target_pos: Vector2, max_radius: float) -> int:
	var closest_idx = -1
	var min_dist = max_radius
	for cell in cells:
		var dist = cell["screen_pos"].distance_to(target_pos)
		if dist < min_dist:
			min_dist = dist
			closest_idx = cell["index"]
	return closest_idx

func select_cell(cell_idx: int) -> void:
	if cell_idx < 0 or cell_idx >= cells.size():
		return
	selected_cell_index = cell_idx
	queue_redraw()
	if EventBus:
		EventBus.cell_selected.emit(cell_idx, cells[cell_idx])

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

	# Always shape the center cell directly
	if target_terrain == "sink_ocean":
		apply_sink_ocean(center, 0.0)
	else:
		apply_terrain_to_cell(center, target_terrain)
	EventBus.cell_terrain_shaped.emit(center["index"], center["terrain"], center["elevation"])

	if scope == "pinpoint":
		queue_redraw()
		return

	var radius = 2.0 if scope == "regional" else 3.8
	var affected = get_cells_in_radius(center_index, radius)

	for c in affected:
		if c["index"] == center["index"]:
			continue
		var dist = get_cell_distance(center, c)
		if target_terrain == "sink_ocean":
			apply_sink_ocean(c, dist)
		elif target_terrain == "desert":
			apply_desert_cascade(c, dist)
		elif target_terrain == "tundra":
			apply_tundra_cascade(c, dist)
		else:
			if dist < 1.2:
				apply_terrain_to_cell(c, target_terrain)
			elif dist < 2.2 and randf() > 0.3:
				apply_terrain_to_cell(c, target_terrain)
		EventBus.cell_terrain_shaped.emit(c["index"], c["terrain"], c["elevation"])
	queue_redraw()

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
		apply_terrain_to_cell(cell, "desert")
	elif dist < 2.8:
		if cell["terrain"] == "forest":
			cell["terrain"] = "plains"

func apply_tundra_cascade(cell: Dictionary, dist: float) -> void:
	if cell["terrain"] != "mountains" and cell["terrain"] != "hills":
		apply_terrain_to_cell(cell, "tundra")

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
