extends Node
## The Venerable Bede Chronicler (res://scripts/chronicle/chronicler.gd)
## Multi-Age historical recorder and narrative chronicler.

var history_log: Array[Dictionary] = []

func _ready() -> void:
	EventBus.chronicle_entry_logged.connect(_on_entry_logged)
	EventBus.epoch_advanced.connect(_on_epoch_advanced)
	EventBus.battle_resolved.connect(_on_battle_resolved)

func _on_entry_logged(entry: Dictionary) -> void:
	history_log.append(entry)

func _on_epoch_advanced(new_age: int, age_name: String) -> void:
	history_log.append({
		"text": "The cosmos transitioned into the " + age_name + ".",
		"age": new_age,
		"category": "epoch"
	})

func _on_battle_resolved(report: Dictionary) -> void:
	var desc = "A clash occurred: " + report["outcome"]
	if report["city_ruined"]:
		desc += " — The fortress was reduced to smoking ruins!"
	history_log.append({
		"text": desc,
		"age": GameManager.current_age,
		"category": "conflict"
	})
