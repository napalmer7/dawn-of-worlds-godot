extends Node
## Coordinates scene entry; no simulation runs while the menu is open.

signal status_changed(message: String)
var current_save_id: String = ""
var last_error: String = ""
var pending_state: Dictionary = {}
var entering_game: bool = false

func _ready() -> void:
	EventBus.deity_turn_started.connect(_on_turn_started)

func new_game() -> void:
	pending_state = {}
	current_save_id = "world_" + str(int(Time.get_unix_time_from_system() * 1000000.0)) + "_" + str(randi())
	_open_game()

func load_game(id: String) -> bool:
	var state = SaveManager.load_world_state(id)
	if state.is_empty():
		last_error = SaveManager.last_error
		return false
	pending_state = state
	current_save_id = id
	return _open_game()

func continue_game() -> bool:
	for entry in SaveManager.list_saved_games():
		if entry["valid"]: return load_game(entry["id"])
	last_error = "No saved world is available yet. Start a new game to begin."
	return false

func _open_game() -> bool:
	GameManager.is_game_active = false
	entering_game = true
	var result = get_tree().change_scene_to_file("res://scenes/main.tscn")
	if result != OK:
		entering_game = false
		last_error = "The game scene could not be opened."
		return false
	return true

func enter_game() -> void:
	var scene = get_tree().current_scene
	if scene == null or not scene.has_node("WorldGrid"): return
	if current_save_id.is_empty():
		current_save_id = "world_" + str(int(Time.get_unix_time_from_system() * 1000000.0))
	if pending_state.is_empty():
		GameManager.reset_game()
	else:
		var manager: Dictionary = pending_state["manager"]
		for key in ["current_age", "current_round", "age_round", "current_year", "active_deity_index"]:
			GameManager.set(key, int(manager[key]))
		GameManager.deities.clear()
		for stored in manager["deities"]:
			var deity: Dictionary = stored.duplicate(true)
			deity["color"] = Color.html(deity["color"])
			for key in ["power", "thrift", "last_roll"]: deity[key] = int(deity[key])
			GameManager.deities.append(deity)
		GameManager.turn_order.assign(manager["turn_order"])
		var grid = scene.get_node("WorldGrid")
		grid.cells.assign(pending_state["world"]["cells"])
		grid.selected_indices.clear()
		for index in pending_state["world"]["selected_indices"]: grid.selected_indices.append(int(index))
		grid.ripple_scope = pending_state["world"]["ripple_scope"]
		grid.show_resources = pending_state["world"]["show_resources"]
		grid.queue_redraw()
		scene.get_node("Chronicler").history_log.assign(pending_state["history"])
		GameManager.is_game_active = true
	pending_state = {}
	entering_game = false
	scene.get_node("HUD").refresh_state()
	save_current_game()

func capture_state() -> Dictionary:
	var scene = get_tree().current_scene
	if scene == null or not scene.has_node("WorldGrid"): return {}
	var manager: Dictionary = {}
	for key in ["current_age", "current_round", "age_round", "current_year", "active_deity_index"]: manager[key] = GameManager.get(key)
	manager["turn_order"] = GameManager.turn_order.duplicate()
	manager["deities"] = GameManager.deities.duplicate(true)
	for deity in manager["deities"]: deity["color"] = deity["color"].to_html()
	var grid = scene.get_node("WorldGrid")
	return {"version": SaveManager.VERSION, "id": current_save_id, "manager": manager,
		"world": {"cells": grid.cells.duplicate(true), "selected_indices": grid.selected_indices.duplicate(), "ripple_scope": grid.ripple_scope, "show_resources": grid.show_resources},
		"history": scene.get_node("Chronicler").history_log.duplicate(true)}

func save_current_game() -> bool:
	if entering_game or not GameManager.is_deity_turn("player_deity"):
		last_error = "Wait for your turn before saving."
		return false
	if not SaveManager.save_world_state(capture_state()):
		last_error = SaveManager.last_error
		status_changed.emit(last_error)
		return false
	last_error = ""
	status_changed.emit("World saved.")
	return true

func return_to_menu() -> bool:
	if not save_current_game(): return false
	GameManager.is_game_active = false
	if get_tree().change_scene_to_file("res://scenes/start_menu.tscn") != OK:
		GameManager.is_game_active = true
		last_error = "The menu could not be opened. Your world has been saved."
		status_changed.emit(last_error)
		return false
	return true

func _on_turn_started(deity_id: String) -> void:
	if deity_id == "player_deity" and not entering_game:
		call_deferred("_autosave")

func _autosave() -> void:
	if not entering_game and GameManager.is_deity_turn("player_deity"):
		save_current_game()
