extends CanvasLayer
## In-game Main HUD Controller (res://scripts/ui/main_hud.gd)

@onready var epoch_label = $TopBar/Margin/HBox/EpochLabel
@onready var power_label = $TopBar/Margin/HBox/PowerLabel
@onready var end_turn_btn = $TopBar/Margin/HBox/EndTurnButton

func _ready() -> void:
	EventBus.round_started.connect(_on_round_started)
	EventBus.deity_power_changed.connect(_on_power_changed)
	if end_turn_btn:
		end_turn_btn.pressed.connect(_on_end_turn_pressed)

func _on_round_started(round_number: int, age: int, year: int) -> void:
	if epoch_label:
		epoch_label.text = "Age " + str(age) + " • Round " + str(round_number) + " (Year " + str(year) + ")"

func _on_power_changed(deity_id: String, new_power: int, delta: int) -> void:
	if deity_id == "player_deity" and power_label:
		power_label.text = "Power: " + str(new_power) + " Pts"

func _on_end_turn_pressed() -> void:
	GameManager.end_turn("player_deity")
