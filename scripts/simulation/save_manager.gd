extends Node
## Save & Load Manager (res://scripts/simulation/save_manager.gd)
## Manages auto-saves (every 5 turns by default) and JSON state serialization.

const SAVE_FILE_PATH = "user://dawn_of_worlds_save.json"

func save_world_state(game_state: Dictionary) -> bool:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		return false
	var json_str = JSON.stringify(game_state, "  ")
	file.store_string(json_str)
	file.close()
	return true

func load_world_state() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return {}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	var json = JSON.new()
	if json.parse(text) == OK:
		return json.data
	return {}
