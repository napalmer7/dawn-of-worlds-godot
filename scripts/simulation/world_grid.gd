extends Node2D
## Cartographer's 2D World Atlas (24 Latitudinal Bands x 48 Meridians = 1,152 Blocks)
## (res://scripts/simulation/world_grid.gd)
## Renders the world map, 11 terrain classes, 2-stage ocean sinking, and handles multi-block drag selection.

const ROWS: int = 24
const COLS: int = 48
const TOTAL_BLOCKS: int = 1152

const TERRAIN_TYPES = {
	"deep_ocean": { "color": Color(0.05, 0.12, 0.20), "name": "Deep Ocean", "is_water": true },
	"ocean": { "color": Color(0.22, 0.74, 0.97), "name": "Ocean / Shallows", "is_water": true },
	"shallow_water": { "color": Color(0.22, 0.74, 0.97), "name": "Lake / Shallows", "is_water": true },
	"plains": { "color": Color(0.29, 0.49, 0.16), "name": "Plains", "is_water": false },
	"forest": { "color": Color(0.14, 0.36, 0.15), "name": "Forest", "is_water": false },
	"hills": { "color": Color(0.76, 0.38, 0.10), "name": "Hills", "is_water": false },
	"mountains": { "color": Color(0.42, 0.45, 0.50), "name": "Mountain", "is_water": false },
	"swamp": { "color": Color(0.18, 0.34, 0.26), "name": "Swamp", "is_water": false },
	"desert": { "color": Color(0.92, 0.70, 0.26), "name": "Desert", "is_water": false },
	"volcanic": { "color": Color(0.50, 0.11, 0.11), "name": "Volcanic", "is_water": false },
	"tundra": { "color": Color(0.80, 0.84, 0.88), "name": "Frozen Tundra", "is_water": false }
}

var cells: Array[Dictionary] = []
var selected_indices: Array[int] = [14 * 48 + 28]
var hovered_index: int = -1
var is_mouse_down: bool = false
var ripple_scope: String = "cascade"
var show_resources: bool = true

var atlas_origin: Vector2 = Vector2(24, 80)
var atlas_size: Vector2 = Vector2(880, 440)
var block_w: float = 880.0 / 48.0
var block_h: float = 440.0 / 24.0

func _ready() -> void:
	generate_equirectangular_atlas()
	if EventBus:
		EventBus.cell_terrain_shaped.connect(func(_idx, _t, _e): queue_redraw())
		EventBus.catastrophe_unleashed.connect(func(_idx, _t, _c): queue_redraw())
		EventBus.city_founded.connect(func(_d): queue_redraw())
	queue_redraw()
	if not selected_indices.is_empty():
		call_deferred("emit_selection_signal")

func generate_equirectangular_atlas() -> void:
	cells.clear()
	var idx = 0
	for r in range(ROWS):
		var lat = 90.0 - (float(r) / float(ROWS - 1)) * 180.0
		for c in range(COLS):
			var lon = -180.0 + (float(c) / float(COLS)) * 360.0

			var terrain = "deep_ocean"
			var elevation = -0.75

			var in_nw_land = (r >= 9 and r <= 15 and c >= 3 and c <= 11)
			var in_nw_coast = (r >= 8 and r <= 16 and c >= 2 and c <= 13 and not in_nw_land)

			var in_mid_land = (r >= 11 and r <= 14 and c >= 24 and c <= 30)
			var in_mid_coast = (
				((r >= 10 and r <= 15 and c >= 22 and c <= 34) or (r >= 8 and r <= 10 and c >= 16 and c <= 25)) and not in_mid_land
			)

			var in_se_land = (
				(r >= 13 and c >= 35 and (r - 13) * 1.5 + (c - 35) >= 0) or
				(r >= 15 and c >= 28 and (r - 15) * 1.8 + (c - 28) >= 0) or
				(r >= 18 and c >= 22)
			)
			var in_se_coast = (
				((r >= 12 and c >= 33 and (r - 12) * 1.5 + (c - 33) >= -2) or
				 (r >= 14 and c >= 26 and (r - 14) * 1.8 + (c - 26) >= -2) or
				 (r >= 17 and c >= 20)) and not in_se_land
			)

			var is_polar_south = (r >= 21)

			if in_nw_land:
				elevation = 0.4
				if c == 4 or c == 5 or r == 14: terrain = "hills"
				elif c == 7 or c == 8: terrain = "forest"
				elif c == 10: terrain = "mountains"
				else: terrain = "plains"
			elif in_nw_coast:
				terrain = "ocean"
				elevation = -0.05
			elif in_mid_land:
				elevation = 0.35
				if c <= 25: terrain = "hills"
				elif c == 27 or c == 28: terrain = "forest"
				else: terrain = "plains"
			elif in_mid_coast:
				terrain = "ocean"
				elevation = -0.05
			elif in_se_land:
				elevation = 0.5
				if is_polar_south:
					terrain = "tundra"
					elevation = 0.2
				elif r <= 15 and c <= 33:
					terrain = "hills"
				elif r >= 16 and r <= 18 and c >= 34 and c <= 41:
					terrain = "mountains"
				elif r >= 14 and r <= 18 and c >= 26 and c <= 33:
					terrain = "forest" if (r + c) % 3 == 0 else "plains"
				elif r >= 18 and r <= 20 and c >= 28 and c <= 38:
					terrain = "swamp" if (r + c) % 4 == 0 else "forest"
				else:
					terrain = "plains" if c % 2 == 0 else "forest"
			elif in_se_coast:
				terrain = "ocean"
				elevation = -0.05
			else:
				terrain = "deep_ocean"
				elevation = -0.75

			var resource_type = ""
			var seed_hash = sin(float(r) * 37.1 + float(c) * 83.3) * 10000.0
			var rand_val = seed_hash - floor(seed_hash)
			var is_dry = not TERRAIN_TYPES[terrain]["is_water"]

			if (is_dry and rand_val > 0.82) or (terrain == "ocean" and rand_val > 0.94):
				if terrain == "mountains" or terrain == "hills":
					resource_type = "mithril" if rand_val > 0.92 else "ore_gold"
				elif terrain == "forest" or terrain == "plains":
					if rand_val > 0.93: resource_type = "mana_springs"
					elif rand_val > 0.88: resource_type = "ore_gold"
					else: resource_type = "river_delta"
				elif terrain == "tundra":
					resource_type = "mithril" if rand_val > 0.90 else "ore_gold"
				elif terrain == "ocean" and rand_val > 0.94:
					resource_type = "river_delta"

			cells.append({
				"index": idx,
				"row": r,
				"col": c,
				"lat": lat,
				"lon": lon,
				"elevation": elevation,
				"terrain": terrain,
				"resource_type": resource_type,
				"city_id": "",
				"city_name": "",
				"population": 0
			})
			idx += 1

func _draw() -> void:
	var card_rect = Rect2(atlas_origin.x - 8, atlas_origin.y - 28, atlas_size.x + 16, atlas_size.y + 110)
	draw_rect(card_rect, Color(0.04, 0.06, 0.10), true)
	draw_rect(card_rect, Color(0.40, 0.25, 0.12, 0.5), false, 1.5)

	var font = ThemeDB.fallback_font
	if font:
		draw_string(font, Vector2(atlas_origin.x, atlas_origin.y - 12), "CARTOGRAPHER'S TABLE: 2D WORLD ATLAS", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.98, 0.82, 0.35))
		draw_string(font, Vector2(atlas_origin.x + 320, atlas_origin.y - 12), "Equirectangular (24x48 - 1152 Blocks)", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.6, 0.65, 0.75))

	for cell in cells:
		var r = cell["row"]
		var c = cell["col"]
		var x = atlas_origin.x + float(c) * block_w
		var y = atlas_origin.y + float(r) * block_h
		var block_rect = Rect2(x, y, block_w, block_h)

		var terrain_type = cell["terrain"]
		var color = TERRAIN_TYPES.get(terrain_type, TERRAIN_TYPES["ocean"])["color"]

		draw_rect(block_rect, color, true)
		draw_rect(block_rect, Color(0.02, 0.05, 0.09, 0.5), false, 1.0)

		if show_resources and cell["resource_type"] != "":
			var center = Vector2(x + block_w * 0.5, y + block_h * 0.5)
			match cell["resource_type"]:
				"mithril":
					var pts = PackedVector2Array([center + Vector2(0, -4), center + Vector2(4, 0), center + Vector2(0, 4), center + Vector2(-4, 0)])
					draw_colored_polygon(pts, Color(0.22, 0.74, 0.97))
				"ore_gold":
					draw_rect(Rect2(center - Vector2(3, 3), Vector2(6, 6)), Color(0.98, 0.75, 0.14), true)
				"mana_springs":
					draw_circle(center, 3.5, Color(0.75, 0.52, 0.98))
				"river_delta":
					draw_circle(center, 3.0, Color(0.29, 0.87, 0.50))

		if cell["city_id"] != "":
			var center = Vector2(x + block_w * 0.5, y + block_h * 0.5)
			draw_rect(Rect2(center - Vector2(4, 4), Vector2(8, 8)), Color(1.0, 0.9, 0.2), true)

		if cell["index"] == hovered_index and not selected_indices.has(cell["index"]):
			draw_rect(block_rect, Color(1.0, 1.0, 1.0, 0.6), false, 1.5)

		if selected_indices.has(cell["index"]):
			draw_rect(block_rect, Color(1.0, 0.85, 0.2), false, 2.0)

	var status_y = atlas_origin.y + atlas_size.y + 16
	draw_rect(Rect2(atlas_origin.x, status_y, atlas_size.x, 26), Color(0.06, 0.09, 0.15), true)
	draw_rect(Rect2(atlas_origin.x, status_y, atlas_size.x, 26), Color(0.18, 0.24, 0.36), false, 1.0)

	if font:
		var status_text = ""
		if selected_indices.size() > 1:
			status_text = "Target: " + str(selected_indices.size()) + " blocks selected. Ready for divine cascade."
		elif not selected_indices.is_empty():
			var s_cell = cells[selected_indices[0]]
			status_text = "Survey: Block #" + str(s_cell["index"]) + " (R" + str(s_cell["row"]) + ", C" + str(s_cell["col"]) + ") • " + TERRAIN_TYPES[s_cell["terrain"]]["name"] + " • Elev: " + str(snappedf(s_cell["elevation"], 0.01))
			if s_cell["resource_type"] != "":
				status_text += " • Resource: " + s_cell["resource_type"].capitalize()
		draw_string(font, Vector2(atlas_origin.x + 12, status_y + 18), status_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.9, 0.85, 0.7))

	var leg_y = status_y + 38
	if font:
		draw_string(font, Vector2(atlas_origin.x, leg_y), "Lake/Shallows [Cyan]  Ocean [Navy]  Plains [Green]  Forest [DarkGreen]  Mountain [Grey]  Hills [Orange]  Desert [Gold]", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.65, 0.7, 0.8))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = event.position
		var idx = get_cell_index_at_pos(mouse_pos)
		if idx != hovered_index:
			hovered_index = idx
			if is_mouse_down and idx != -1 and not selected_indices.has(idx):
				selected_indices.append(idx)
				emit_selection_signal()
			queue_redraw()

	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var mouse_pos = event.position
			var idx = get_cell_index_at_pos(mouse_pos)
			if idx != -1:
				is_mouse_down = true
				if event.shift_pressed:
					if selected_indices.has(idx):
						selected_indices.erase(idx)
					else:
						selected_indices.append(idx)
				else:
					selected_indices = [idx]
				emit_selection_signal()
				queue_redraw()
		else:
			is_mouse_down = false

func get_cell_index_at_pos(pos: Vector2) -> int:
	if pos.x < atlas_origin.x or pos.x >= atlas_origin.x + atlas_size.x:
		return -1
	if pos.y < atlas_origin.y or pos.y >= atlas_origin.y + atlas_size.y:
		return -1
	var c = int((pos.x - atlas_origin.x) / block_w)
	var r = int((pos.y - atlas_origin.y) / block_h)
	c = clampi(c, 0, COLS - 1)
	r = clampi(r, 0, ROWS - 1)
	return r * COLS + c

func emit_selection_signal() -> void:
	if selected_indices.is_empty():
		return
	var first_cell = cells[selected_indices[0]]
	if EventBus:
		EventBus.cell_selected.emit(selected_indices[0], first_cell)

func compute_distance(c1: Dictionary, c2: Dictionary) -> float:
	var dy = abs(float(c1["row"] - c2["row"]))
	var raw_dx = abs(float(c1["col"] - c2["col"]))
	var dx = minf(raw_dx, float(COLS) - raw_dx)
	return sqrt(dx * dx + dy * dy)

func invoke_divine_power(target_terrain: String, _cost: int) -> bool:
	if selected_indices.is_empty():
		return false
	if not GameManager.spend_power("player_deity", "shape_land"):
		return false

	for idx in selected_indices:
		var center = cells[idx]
		if target_terrain == "sink_ocean":
			center["elevation"] = -0.85
			center["terrain"] = "deep_ocean"
		elif target_terrain == "shallow_water":
			center["elevation"] = -0.05
			center["terrain"] = "ocean"
		else:
			apply_terrain_to_cell(center, target_terrain)
		EventBus.cell_terrain_shaped.emit(center["index"], center["terrain"], center["elevation"])

	if ripple_scope != "pinpoint":
		var max_radius = 2.2 if ripple_scope == "regional" else 4.2
		for cell in cells:
			if selected_indices.has(cell["index"]):
				continue
			var min_dist = 999.0
			for idx in selected_indices:
				var center = cells[idx]
				var d = compute_distance(center, cell)
				if d < min_dist:
					min_dist = d

			if min_dist <= max_radius:
				if target_terrain == "sink_ocean":
					if min_dist <= 1.5:
						cell["elevation"] = -0.65
						cell["terrain"] = "deep_ocean"
					elif min_dist <= 2.8:
						cell["elevation"] = -0.05
						cell["terrain"] = "ocean"
				elif target_terrain == "shallow_water":
					if min_dist <= 1.5:
						cell["elevation"] = -0.05
						cell["terrain"] = "ocean"
				elif target_terrain == "desert":
					if min_dist <= 1.8:
						apply_terrain_to_cell(cell, "desert")
					elif min_dist <= 3.2 and cell["terrain"] == "forest":
						cell["terrain"] = "plains"
				elif target_terrain == "tundra":
					if cell["terrain"] != "mountains" and cell["terrain"] != "hills":
						apply_terrain_to_cell(cell, "tundra")
				elif target_terrain == "volcanic":
					if min_dist <= 1.5:
						apply_terrain_to_cell(cell, "mountains")
					elif min_dist <= 2.8:
						apply_terrain_to_cell(cell, "hills")
				elif target_terrain == "mountains":
					if min_dist <= 1.6:
						apply_terrain_to_cell(cell, "hills")
				else:
					if min_dist <= 1.4:
						apply_terrain_to_cell(cell, target_terrain)
					elif min_dist <= 2.6 and randf() > 0.4:
						apply_terrain_to_cell(cell, target_terrain)
				EventBus.cell_terrain_shaped.emit(cell["index"], cell["terrain"], cell["elevation"])

	queue_redraw()
	return true

func apply_terrain_to_cell(cell: Dictionary, terrain_name: String) -> void:
	cell["terrain"] = terrain_name
	match terrain_name:
		"mountains": cell["elevation"] = maxf(cell["elevation"], 0.75)
		"hills": cell["elevation"] = clampf(cell["elevation"], 0.35, 0.65)
		"plains", "forest", "swamp", "desert": cell["elevation"] = clampf(cell["elevation"], 0.1, 0.4)
		"volcanic": cell["elevation"] = maxf(cell["elevation"], 0.65)
		"tundra": cell["elevation"] = maxf(0.1, cell["elevation"])
		"deep_ocean": cell["elevation"] = -0.75
		"ocean", "shallow_water": cell["elevation"] = -0.05
