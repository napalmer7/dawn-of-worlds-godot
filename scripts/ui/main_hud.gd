extends CanvasLayer
## In-game Main HUD Controller (res://scripts/ui/main_hud.gd)
## Coordinates Top Navigation and the Right-Hand Divine Powers Drawer matching the master mockup.

@onready var epoch_label = $TopBar/Margin/HBox/EpochLabel
@onready var year_label = $TopBar/Margin/HBox/YearLabel
@onready var power_label = $TopBar/Margin/HBox/PowerLabel
@onready var end_turn_btn = $TopBar/Margin/HBox/EndTurnButton

@onready var power_avail_label = $PowersDrawer/Margin/VBox/HeaderBox/PowerAvailLabel
@onready var target_label = $PowersDrawer/Margin/VBox/HeaderBox/TargetLabel

@onready var btn_cascade = $PowersDrawer/Margin/VBox/ScopeBox/BtnCascade
@onready var btn_regional = $PowersDrawer/Margin/VBox/ScopeBox/BtnRegional
@onready var btn_pinpoint = $PowersDrawer/Margin/VBox/ScopeBox/BtnPinpoint

@onready var btn_volcanic = $PowersDrawer/Margin/VBox/TerrainGrid/BtnVolcanic
@onready var btn_mountains = $PowersDrawer/Margin/VBox/TerrainGrid/BtnMountains
@onready var btn_hills = $PowersDrawer/Margin/VBox/TerrainGrid/BtnHills
@onready var btn_swamp = $PowersDrawer/Margin/VBox/TerrainGrid/BtnSwamp
@onready var btn_forest = $PowersDrawer/Margin/VBox/TerrainGrid/BtnForest
@onready var btn_plains = $PowersDrawer/Margin/VBox/TerrainGrid/BtnPlains
@onready var btn_desert = $PowersDrawer/Margin/VBox/TerrainGrid/BtnDesert
@onready var btn_tundra = $PowersDrawer/Margin/VBox/TerrainGrid/BtnTundra

@onready var btn_lake = $PowersDrawer/Margin/VBox/SinkingBox/BtnLake
@onready var btn_ocean = $PowersDrawer/Margin/VBox/SinkingBox/BtnOcean

var world_grid: Node2D = null

func _ready() -> void:
	world_grid = get_tree().root.find_child("WorldGrid", true, false)

	EventBus.round_started.connect(_on_round_started)
	EventBus.deity_power_changed.connect(_on_power_changed)
	EventBus.cell_selected.connect(_on_cell_selected)

	if end_turn_btn:
		end_turn_btn.pressed.connect(_on_end_turn_pressed)

	# Wire Scope Buttons
	if btn_cascade: btn_cascade.pressed.connect(func(): set_scope("cascade"))
	if btn_regional: btn_regional.pressed.connect(func(): set_scope("regional"))
	if btn_pinpoint: btn_pinpoint.pressed.connect(func(): set_scope("pinpoint"))

	# Wire 8 Geologic Actions
	if btn_volcanic: btn_volcanic.pressed.connect(func(): invoke_terrain("volcanic", 3))
	if btn_mountains: btn_mountains.pressed.connect(func(): invoke_terrain("mountains", 3))
	if btn_hills: btn_hills.pressed.connect(func(): invoke_terrain("hills", 3))
	if btn_swamp: btn_swamp.pressed.connect(func(): invoke_terrain("swamp", 3))
	if btn_forest: btn_forest.pressed.connect(func(): invoke_terrain("forest", 3))
	if btn_plains: btn_plains.pressed.connect(func(): invoke_terrain("plains", 3))
	if btn_desert: btn_desert.pressed.connect(func(): invoke_terrain("desert", 3))
	if btn_tundra: btn_tundra.pressed.connect(func(): invoke_terrain("tundra", 3))

	# Wire 2 Sinking Actions
	if btn_lake: btn_lake.pressed.connect(func(): invoke_terrain("shallow_water", 3))
	if btn_ocean: btn_ocean.pressed.connect(func(): invoke_terrain("sink_ocean", 3))

func set_scope(scope: String) -> void:
	if world_grid:
		world_grid.ripple_scope = scope
		print("Divine Ripple Scope set to: ", scope)

func invoke_terrain(terrain: String, cost: int) -> void:
	if world_grid:
		world_grid.invoke_divine_power(terrain, cost)

func _on_round_started(round_number: int, age: int, year: int) -> void:
	if epoch_label:
		epoch_label.text = "1st Age: Age of Land (Round " + str(round_number) + "/5)" if age == 1 else "Age " + str(age) + " • Round " + str(round_number)
	if year_label:
		year_label.text = "Year " + str(year)
	if end_turn_btn:
		end_turn_btn.text = "End Turn > ROUND " + str(round_number)

func _on_power_changed(deity_id: String, new_power: int, _delta: int) -> void:
	if deity_id == "player_deity":
		if power_label:
			power_label.text = "⚡ " + str(new_power) + " Pts"
		if power_avail_label:
			power_avail_label.text = "⚡ Available Power: " + str(new_power) + " Pts"

func _on_cell_selected(_cell_idx: int, _cell_data: Dictionary) -> void:
	if target_label and world_grid:
		var count = world_grid.selected_indices.size()
		if count > 1:
			target_label.text = "Target: " + str(count) + " blocks selected"
		elif count == 1:
			target_label.text = "Target: Block #" + str(world_grid.selected_indices[0]) + " selected"
		else:
			target_label.text = "Target: Click or drag on atlas"

func _on_end_turn_pressed() -> void:
	GameManager.end_turn("player_deity")
