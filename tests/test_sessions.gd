extends SceneTree

var failures: int = 0
var checks: int = 0
var completed: bool = false

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var manager = root.get_node("GameManager")
	check(not manager.is_game_active, "launch leaves simulation inactive")
	check(manager.has_method("reset_game"), "explicit new-game reset exists")
	check(root.has_node("SaveManager"), "save service registered")
	check(root.has_node("SessionController"), "session entry service registered")
	check(ProjectSettings.get_setting("application/run/main_scene") == "res://scenes/start_menu.tscn", "launch opens start menu")
	if failures:
		quit(1)
		return
	await test_sessions()
	check(completed, "all session scenarios reached completion")
	print("Session tests: ", checks, " checks, ", failures, " failures")
	quit(1 if failures else 0)

func test_sessions() -> void:
	var session = root.get_node("SessionController")
	var saves = root.get_node("SaveManager")
	var manager = root.get_node("GameManager")
	# A separate process user-data directory is required by the test command.
	check(OS.get_environment("DAWN_TEST_RUN") == "1", "test storage explicitly isolated")
	if OS.get_environment("DAWN_TEST_RUN") != "1": return
	saves.save_directory = "user://session_tests_" + str(Time.get_ticks_usec())
	check(saves.list_saved_games().is_empty(), "fresh storage is empty")
	change_scene_to_file("res://scenes/start_menu.tscn")
	await process_frame
	await process_frame
	check(current_scene.continue_button.disabled, "Continue disabled without saves")
	check(manager.turn_order.is_empty(), "menu does not initialize turns")
	current_scene.load_button.pressed.emit()
	check(current_scene.save_list.visible, "Load Game opens the save browser")
	check(current_scene.message_label.text.contains("No saved worlds"), "empty load list explains how to begin")
	current_scene.save_list.get_children().back().pressed.emit()
	current_scene.new_button.pressed.emit()
	await process_frame
	await process_frame
	await process_frame
	check(manager.is_game_active, "new game is active")
	check(manager.current_round == 1 and manager.age_round == 1, "new game starts in round 1")
	check(manager.current_year == 500, "new game starts at year 500")
	check(manager.is_deity_turn("player_deity"), "new game reaches player turn")
	var round_before = manager.current_round
	manager.end_turn("solaria")
	check(manager.current_round == round_before and manager.is_deity_turn("player_deity"), "wrong deity cannot end player turn")
	var grid = current_scene.get_node("WorldGrid")
	manager.get_deity_by_id("player_deity")["power"] = 12
	grid.selected_indices.assign([700, 701])
	grid.ripple_scope = "pinpoint"
	check(grid.invoke_divine_power("volcanic", 3), "player shapes land")
	current_scene.get_node("Chronicler").history_log.append({"text": "Test creation", "age": 1})
	manager.end_turn("player_deity")
	await process_frame
	await process_frame
	check(manager.current_round == 2, "first end turn completes exactly one round")
	check(session.save_current_game(), "save succeeds")
	var first_id = session.current_save_id
	var checkpoint = session.capture_state()
	check(session.return_to_menu(), "return to menu saves and succeeds")
	await process_frame
	await process_frame
	check(not manager.is_game_active, "menu deactivates simulation")
	var menu = current_scene
	check(not menu.continue_button.disabled, "Continue enabled after saving")
	check(menu.settings_button.disabled, "Settings is unavailable")
	menu.show_saves()
	var first_world_label = menu.save_list.get_child(0).text.get_slice("\n", 0)
	manager.end_turn("player_deity")
	check(manager.current_round == 2, "menu rejects end turn")
	check(not manager.spend_power("player_deity", "shape_land"), "menu rejects spending")
	session.new_game()
	await process_frame
	await process_frame
	await process_frame
	check(manager.current_round == 1, "second new game resets round")
	check(session.current_save_id != first_id, "new world has separate save")
	check(saves.list_saved_games().size() == 2, "new game retains earlier world")
	check(session.return_to_menu(), "return with two independent worlds")
	await process_frame
	await process_frame
	current_scene.show_saves()
	check(current_scene.save_list.get_child(1).text.get_slice("\n", 0) == first_world_label, "world identity survives moving down the list")
	check(session.load_game(first_id), "load earlier game succeeds")
	await process_frame
	await process_frame
	await process_frame
	check(not report_difference(checkpoint, session.capture_state(), "state"), "load restores complete snapshot without extra rolls")
	check(saves.list_saved_games()[0]["id"] == first_id, "Continue follows last played world")
	var bad = checkpoint.duplicate(true)
	bad["manager"]["active_deity_index"] = 100
	check(not saves.save_world_state(bad), "invalid initiative rejected")
	bad = checkpoint.duplicate(true)
	bad["world"]["cells"][0]["terrain"] = "invalid"
	check(not saves.save_world_state(bad), "invalid terrain rejected")
	bad = checkpoint.duplicate(true)
	bad["version"] = 999
	check(not saves.save_world_state(bad), "future version rejected")
	var corrupt = FileAccess.open(saves.save_directory.path_join("corrupt.json"), FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt.close()
	check(not session.load_game("corrupt"), "malformed save rejected")
	check(not report_difference(checkpoint, session.capture_state(), "state"), "failed load preserves live session")
	var original_directory = saves.save_directory
	saves.save_directory = "res://project.godot/unwritable"
	check(not session.return_to_menu(), "failed save prevents leaving game")
	check(manager.is_game_active, "failed save keeps session active")
	saves.save_directory = original_directory
	check(session.return_to_menu(), "return after recovering storage succeeds")
	await process_frame
	await process_frame
	check(session.continue_game(), "Continue opens last played game")
	await process_frame
	await process_frame
	await process_frame
	check(not report_difference(checkpoint, session.capture_state(), "state"), "Continue restores checkpoint")
	check(session.return_to_menu(), "return for save list keyboard checks")
	await process_frame
	await process_frame
	root.content_scale_size = Vector2i(800, 480)
	root.size = Vector2i(800, 480)
	current_scene.show_saves()
	await process_frame
	await process_frame
	check(current_scene.save_list.get_child(0).text.get_slice("\n", 0) == first_world_label, "world label stays stable when sorting changes")
	var back_button = current_scene.save_list.get_children().back()
	back_button.grab_focus()
	await process_frame
	await process_frame
	check(back_button.get_global_rect().end.y <= root.get_visible_rect().size.y, "keyboard-focused Back stays visible in short window")
	completed = true

func report_difference(expected: Variant, actual: Variant, path: String) -> bool:
	if expected is Dictionary and actual is Dictionary:
		for key in expected:
			if report_difference(expected[key], actual.get(key), path + "/" + str(key)): return true
	elif expected is Array and actual is Array:
		if expected.size() != actual.size():
			print("DIFFERENCE ", path, " sizes ", expected.size(), " != ", actual.size())
			return true
		for index in expected.size():
			if report_difference(expected[index], actual[index], path + "/" + str(index)): return true
	elif expected is float and (actual is float or actual is int):
		# JSON's decimal parser may round the final binary digit; geography must
		# round-trip within a trillionth, while integer economy/time stay exact.
		if absf(expected - float(actual)) > 0.000000000001:
			print("DIFFERENCE ", path, " ", expected, " != ", actual)
			return true
	elif expected != actual:
		print("DIFFERENCE ", path, " ", expected, " != ", actual, " types ", typeof(expected), "/", typeof(actual))
		return true
	return false
