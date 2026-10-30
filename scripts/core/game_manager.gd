extends Node
## Master Game Manager (res://scripts/core/game_manager.gd)
## Controls turn execution, epochal transitions, demographics, and AI deity coordination.

const AGE_CONFIG = {
	1: { "name": "First Dawn — Age of Order & Shaping", "max_rounds": 5, "years_per_round": 500 },
	2: { "name": "The Second Age — Awakening of Mortal Kind", "max_rounds": 5, "years_per_round": 100 },
	3: { "name": "The Third Age — Era of Empires & Orders", "max_rounds": 999999, "years_per_round": 10 }
}

var current_age: int = 1
var current_round: int = 1
var age_round: int = 1
var current_year: int = 500

var deities: Array[Dictionary] = []
var turn_order: Array[String] = []
var active_deity_index: int = 0
var is_game_active: bool = false

func _ready() -> void:
	initialize_default_pantheon()

func initialize_default_pantheon() -> void:
	deities = [
		{
			"id": "player_deity",
			"name": "Sol-Adon",
			"title": "The First Architect",
			"domain": "Creation & Light",
			"is_player": true,
			"power": 12,
			"thrift": 0,
			"last_roll": 7,
			"color": Color(0.95, 0.75, 0.2)
		},
		{
			"id": "solaria",
			"name": "Solaria",
			"title": "Lady of the Dawning Sun",
			"domain": "Light & Virtue",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 6,
			"color": Color(0.98, 0.85, 0.3)
		},
		{
			"id": "ignis_khan",
			"name": "Ignis-Khan",
			"title": "The Pyre Sovereign",
			"domain": "Volcanoes & Martial Fire",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 8,
			"color": Color(0.9, 0.25, 0.15)
		},
		{
			"id": "zephyros",
			"name": "Zephyros",
			"title": "Lord of Roaring Winds",
			"domain": "Tempests & Exploration",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 5,
			"color": Color(0.3, 0.7, 0.95)
		},
		{
			"id": "gorgoroth",
			"name": "Gorgoroth",
			"title": "The World-Breaker",
			"domain": "Earthquakes & Destruction",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 7,
			"color": Color(0.5, 0.35, 0.2)
		},
		{
			"id": "elysia",
			"name": "Elysia",
			"title": "The Verdant Mother",
			"domain": "Flora & Primeval Life",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 6,
			"color": Color(0.2, 0.8, 0.35)
		},
		{
			"id": "nyxathor",
			"name": "Nyxathor",
			"title": "The Void Gazer",
			"domain": "Shadow & Malevolent Curses",
			"is_player": false,
			"power": 10,
			"thrift": 0,
			"last_roll": 9,
			"color": Color(0.6, 0.2, 0.8)
		}
	]

func start_round() -> void:
	var initiative_rolls: Array[Dictionary] = []
	for deity in deities:
		var gain = RulesEngine.calculate_power_gain(deity["thrift"])
		deity["power"] += gain["total_gained"]
		deity["last_roll"] = gain["dice"]["total"]
		initiative_rolls.append({ "id": deity["id"], "roll": gain["dice"]["total"] })
		EventBus.deity_power_changed.emit(deity["id"], deity["power"], gain["total_gained"])

	initiative_rolls.sort_custom(func(a, b): return a["roll"] > b["roll"])
	turn_order.clear()
	for item in initiative_rolls:
		turn_order.append(item["id"])

	active_deity_index = 0
	EventBus.round_started.emit(current_round, current_age, current_year)
	start_next_turn()

func start_next_turn() -> void:
	if active_deity_index >= turn_order.size():
		conclude_round()
		return

	var current_deity_id = turn_order[active_deity_index]
	var deity = get_deity_by_id(current_deity_id)
	EventBus.deity_turn_started.emit(current_deity_id)

	if not deity["is_player"]:
		var ai_node = get_node_or_null("/root/Main/NpcDeityAI")
		if ai_node and ai_node.has_method("execute_turn"):
			ai_node.execute_turn(deity, current_age)
		else:
			end_turn(deity["id"])

func end_turn(deity_id: String) -> void:
	var deity = get_deity_by_id(deity_id)
	if deity:
		deity["thrift"] = RulesEngine.calculate_new_thrift(deity["power"], deity["thrift"])
	EventBus.deity_turn_ended.emit(deity_id)
	active_deity_index += 1
	start_next_turn()

func conclude_round() -> void:
	var years_passed = AGE_CONFIG[current_age]["years_per_round"]
	current_year += years_passed
	EventBus.round_ended.emit(current_round, current_age)

	if current_age == 1 and age_round >= 5:
		advance_epoch(2)
	elif current_age == 2 and age_round >= 5:
		advance_epoch(3)
	else:
		current_round += 1
		age_round += 1
		start_round()

func advance_epoch(new_age: int) -> void:
	current_age = new_age
	age_round = 1
	current_round += 1
	var age_name = AGE_CONFIG[current_age]["name"]
	EventBus.epoch_advanced.emit(current_age, age_name)
	start_round()

func spend_power(deity_id: String, action_key: String) -> bool:
	var deity = get_deity_by_id(deity_id)
	if not deity:
		return false
	var cost = RulesEngine.get_power_cost(action_key, current_age)
	if deity["power"] < cost:
		return false
	deity["power"] -= cost
	EventBus.deity_power_changed.emit(deity_id, deity["power"], -cost)
	return true

func get_deity_by_id(deity_id: String) -> Dictionary:
	for d in deities:
		if d["id"] == deity_id:
			return d
	return {}
