extends Control

const GOLD = Color("dfbf7c")
const MUTED = Color("929eb5")
var continue_button: Button
var settings_button: Button
var new_button: Button
var load_button: Button
var message_label: Label
var heading: Label
var save_list: VBoxContainer
var menu_buttons: VBoxContainer

func _ready() -> void:
	GameManager.is_game_active = false
	get_tree().auto_accept_quit = true
	_build_theme()
	var scroll = ScrollContainer.new()
	scroll.follow_focus = true
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var center = CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(center)
	var margins = MarginContainer.new()
	for edge in ["left", "right", "top", "bottom"]: margins.add_theme_constant_override("margin_" + edge, 32)
	center.add_child(margins)
	var column = VBoxContainer.new()
	column.custom_minimum_size.x = 440
	column.add_theme_constant_override("separation", 14)
	margins.add_child(column)
	_label(column, "✦", 40, GOLD)
	_label(column, "D A W N   O F   W O R L D S", 28, GOLD)
	_label(column, "G E N E S I S   O F   D E I T I E S", 14, MUTED)
	var divider = HSeparator.new()
	column.add_child(divider)
	heading = _label(column, "Every world begins with a first dawn.", 17, Color("d6ddea"))
	menu_buttons = VBoxContainer.new()
	menu_buttons.add_theme_constant_override("separation", 10)
	column.add_child(menu_buttons)
	continue_button = _button(menu_buttons, "Continue", _continue)
	new_button = _button(menu_buttons, "New Game", _new_game)
	load_button = _button(menu_buttons, "Load Game", show_saves)
	settings_button = _button(menu_buttons, "Settings · Coming soon", func(): pass)
	settings_button.disabled = true
	settings_button.tooltip_text = "Settings will be added in a future update."
	save_list = VBoxContainer.new()
	save_list.add_theme_constant_override("separation", 10)
	save_list.visible = false
	column.add_child(save_list)
	message_label = _label(column, "", 14, MUTED)
	message_label.custom_minimum_size.y = 40
	_label(column, "SHAPE THE LAND  ·  AWAKEN LIFE  ·  WRITE HISTORY", 11, MUTED)
	var has_save = false
	for entry in SaveManager.list_saved_games():
		if entry["valid"]:
			has_save = true
			break
	continue_button.disabled = not has_save
	if not has_save:
		continue_button.tooltip_text = "Start a new game to create your first saved world."
		message_label.text = "Your worlds will be saved automatically after each turn."
	if has_save: continue_button.grab_focus()
	else: new_button.grab_focus()
	resized.connect(queue_redraw)

func _build_theme() -> void:
	theme = Theme.new()
	theme.default_font_size = 17
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style = StyleBoxFlat.new()
		style.bg_color = Color("151f30") if state != "hover" else Color("23334a")
		style.border_color = GOLD if state in ["hover", "focus"] else Color("39404e")
		if state == "disabled": style.bg_color = Color("101725")
		style.set_border_width_all(2 if state == "focus" else 1)
		style.set_corner_radius_all(6)
		style.content_margin_left = 22
		style.content_margin_right = 22
		style.content_margin_top = 14
		style.content_margin_bottom = 14
		theme.set_stylebox(state, "Button", style)
	theme.set_color("font_color", "Button", Color("eee2ca"))
	theme.set_color("font_disabled_color", "Button", Color("6d778a"))

func _label(parent: Node, text: String, font_size: int, color: Color) -> Label:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size.y = 52
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _new_game() -> void:
	_lock_buttons()
	SessionController.new_game()

func _continue() -> void:
	if not SessionController.continue_game(): message_label.text = SessionController.last_error
	else: _lock_buttons()

func _load(id: String) -> void:
	if not SessionController.load_game(id): message_label.text = SessionController.last_error
	else: _lock_buttons()

func _lock_buttons() -> void:
	for button in menu_buttons.get_children(): button.disabled = true
	for button in save_list.get_children():
		if button is Button: button.disabled = true

func show_saves() -> void:
	menu_buttons.hide()
	save_list.show()
	heading.text = "Choose a world to return to."
	for child in save_list.get_children():
		save_list.remove_child(child)
		child.queue_free()
	var entries = SaveManager.list_saved_games()
	message_label.text = "No saved worlds yet. Start a new game to begin." if entries.is_empty() else "Each new game keeps its own saved world."
	for entry in entries:
		if not entry["valid"]:
			var unavailable = _button(save_list, "Unavailable save · " + entry["id"], func(): pass)
			unavailable.disabled = true
			unavailable.tooltip_text = entry["error"]
			continue
		var state: Dictionary = entry["manager"]
		var local_seconds = int(entry["last_played"] / 1000000) + int(Time.get_time_zone_from_system()["bias"]) * 60
		var stamp = Time.get_datetime_string_from_unix_time(local_seconds, true)
		var text = "World " + entry["id"].right(6) + " · Age %d · Round %d · Year %d" % [state["current_age"], state["current_round"], state["current_year"]]
		text += "\nLast played: " + stamp + " (local)"
		_button(save_list, text, _load.bind(entry["id"]))
	var back = _button(save_list, "Back", func():
		save_list.hide()
		menu_buttons.show()
		heading.text = "Every world begins with a first dawn."
		message_label.text = ""
		load_button.grab_focus())
	for button in save_list.get_children():
		if button is Button and not button.disabled:
			button.grab_focus()
			return
	back.grab_focus()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("090f1b"))
	# Fixed star positions keep the title screen calm and reproducible.
	for i in range(80):
		var point = Vector2(fposmod(i * 137.51, 1000.0) / 1000.0, fposmod(i * 231.73, 997.0) / 997.0) * size
		draw_circle(point, 1.0 if i % 4 else 1.7, Color(0.75, 0.8, 0.92, 0.14))
	var radius = minf(size.x * 0.48, size.y * 0.62)
	draw_arc(size * 0.5, radius, 0, TAU, 128, Color(0.87, 0.75, 0.49, 0.06), 1.0, true)
	draw_arc(size * 0.5, radius + 14, 0, TAU, 128, Color(0.87, 0.75, 0.49, 0.035), 1.0, true)
