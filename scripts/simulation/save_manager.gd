extends Node
## Versioned independent saves, validated before replacing live state.
const VERSION = 1
const TERRAINS = ["deep_ocean", "ocean", "shallow_water", "plains", "forest", "hills", "mountains", "swamp", "desert", "tundra", "volcanic"]
var save_directory: String = "user://saves"
var last_error: String = ""

func valid_id(id: String) -> bool:
	return not id.is_empty() and id.length() <= 100 and id == id.validate_filename() and not "." in id and not "/" in id and not "\\" in id

func is_integer(value: Variant, minimum: int, maximum: int) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= minimum and value <= maximum

func validate_state(state: Dictionary) -> bool:
	last_error = "This save is damaged or incompatible with this version of the game."
	if state.get("version") != VERSION or not state.get("id") is String or not valid_id(state["id"]): return false
	if not state.get("manager") is Dictionary or not state.get("world") is Dictionary or not state.get("history") is Array: return false
	var manager: Dictionary = state["manager"]
	for key in ["current_age", "current_round", "age_round", "current_year", "active_deity_index"]:
		if not is_integer(manager.get(key), 0, 2147483647): return false
	if manager["current_age"] < 1 or manager["current_age"] > 3 or manager["current_round"] < 1 or manager["age_round"] < 1: return false
	if not manager.get("deities") is Array or not manager.get("turn_order") is Array: return false
	var deities: Array = manager["deities"]
	var order: Array = manager["turn_order"]
	if deities.size() != 7 or order.size() != deities.size(): return false
	var ids: Array = []
	var player_count = 0
	for deity in deities:
		if not deity is Dictionary: return false
		for key in ["id", "name", "title", "domain", "color"]:
			if not deity.get(key) is String: return false
		if deity["id"].is_empty() or deity["id"] in ids or not Color.html_is_valid(deity["color"]): return false
		if not deity.get("is_player") is bool: return false
		if deity["is_player"]:
			player_count += 1
			if deity["id"] != "player_deity": return false
		if not is_integer(deity.get("power"), 0, 2147483647) or not is_integer(deity.get("thrift"), 0, 3) or not is_integer(deity.get("last_roll"), 2, 12): return false
		ids.append(deity["id"])
	if player_count != 1: return false
	var seen: Array = []
	for id in order:
		if not id is String or not id in ids or id in seen: return false
		seen.append(id)
	if manager["active_deity_index"] >= order.size() or order[int(manager["active_deity_index"])] != "player_deity": return false
	var world: Dictionary = state["world"]
	if not world.get("cells") is Array or world["cells"].size() != 1152: return false
	for index in range(world["cells"].size()):
		var cell = world["cells"][index]
		if not cell is Dictionary or cell.get("index") != index or cell.get("row") != int(index / 48) or cell.get("col") != index % 48: return false
		if not cell.get("terrain") in TERRAINS: return false
		for key in ["lat", "lon", "elevation"]:
			if not (cell.get(key) is int or cell.get(key) is float) or not is_finite(float(cell[key])): return false
		for key in ["resource_type", "city_id", "city_name"]:
			if not cell.get(key) is String: return false
		if not is_integer(cell.get("population"), 0, 2147483647): return false
	if not world.get("selected_indices") is Array or not world.get("ripple_scope") in ["cascade", "regional", "pinpoint"] or not world.get("show_resources") is bool: return false
	for index in world["selected_indices"]:
		if not is_integer(index, 0, 1151): return false
	for entry in state["history"]:
		if not entry is Dictionary: return false
	last_error = ""
	return true

func save_world_state(state: Dictionary) -> bool:
	if not validate_state(state): return false
	var parent = ProjectSettings.globalize_path(save_directory)
	while not parent.is_empty() and parent != parent.get_base_dir():
		if FileAccess.file_exists(parent):
			last_error = "The save folder is blocked by a file. Your game is still open."
			return false
		parent = parent.get_base_dir()
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_directory)) != OK:
		last_error = "Could not create the save folder. Your game is still open; try saving again."
		return false
	var record = state.duplicate(true)
	record["last_played"] = int(Time.get_unix_time_from_system() * 1000000.0)
	var path = save_directory.path_join(state["id"] + ".json")
	var temporary = path + ".tmp"
	var file = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Could not write the save. Check available space and folder permissions."
		return false
	file.store_string(JSON.stringify(record, "", true, true))
	file.flush()
	var write_error = file.get_error()
	file.close()
	if write_error != OK:
		last_error = "Saving failed. Your previous save has been preserved."
		return false
	# Preserve the old file until a complete replacement is on disk.
	var backup = path + ".bak"
	var had_original = FileAccess.file_exists(path)
	if had_original:
		if FileAccess.file_exists(backup): DirAccess.remove_absolute(backup)
		if DirAccess.rename_absolute(path, backup) != OK:
			last_error = "Could not replace the previous save. Your game is still open."
			return false
	if DirAccess.rename_absolute(temporary, path) != OK:
		if had_original: DirAccess.rename_absolute(backup, path)
		last_error = "Could not finish saving. Your previous save has been preserved."
		return false
	last_error = ""
	return true

func load_world_state(id: String) -> Dictionary:
	last_error = "That save could not be found."
	if not valid_id(id): return {}
	var path = save_directory.path_join(id + ".json")
	if not FileAccess.file_exists(path): return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "That save could not be opened. Check folder permissions."
		return {}
	var parsed = JSON.new()
	if parsed.parse(file.get_as_text()) != OK or not parsed.data is Dictionary:
		last_error = "That save is damaged and could not be loaded."
		return {}
	var state: Dictionary = parsed.data
	if not validate_state(state): return {}
	if state["id"] != id:
		last_error = "The save name does not match its contents."
		return {}
	return state

func list_saved_games() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var directory = DirAccess.open(save_directory)
	if directory == null: return result
	for filename in directory.get_files():
		if not filename.ends_with(".json"): continue
		var id = filename.trim_suffix(".json")
		var state = load_world_state(id)
		if state.is_empty():
			result.append({"id": id, "valid": false, "error": last_error, "last_played": 0})
		else:
			var played = state.get("last_played", 0)
			if not (played is int or played is float): played = 0
			result.append({"id": id, "valid": true, "manager": state["manager"], "last_played": played})
	result.sort_custom(func(a, b): return a["last_played"] > b["last_played"])
	last_error = ""
	return result
