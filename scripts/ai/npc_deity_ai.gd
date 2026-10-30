extends Node
## Autonomous NPC Deity Pantheon AI (res://scripts/ai/npc_deity_ai.gd)
## Implements distinct portfolios & priority trees for Solaria, Ignis-Khan, Zephyros, Gorgoroth, Elysia, Nyxathor.

func execute_turn(deity: Dictionary, age: int) -> void:
	var deity_id = deity["id"]
	var power = deity["power"]

	match deity_id:
		"solaria":
			if age == 1 and power >= 5:
				GameManager.spend_power(deity_id, "shape_land")
				EventBus.chronicle_entry_logged.emit({
					"text": "Solaria wove golden plains and lush sunlight across the young sphere.",
					"age": age,
					"category": "creation"
				})
			elif age >= 2 and power >= 6:
				GameManager.spend_power(deity_id, "advance_civ")
		"ignis_khan":
			if age == 1 and power >= 5:
				GameManager.spend_power(deity_id, "shape_land")
			elif age >= 2 and power >= 6:
				GameManager.spend_power(deity_id, "advance_civ")
		"gorgoroth":
			if age == 3 and power >= 10:
				GameManager.spend_power(deity_id, "catastrophe")
			elif power >= 5:
				GameManager.spend_power(deity_id, "shape_land")
		_:
			if age == 1 and power >= 5:
				GameManager.spend_power(deity_id, "shape_land")
			elif age >= 2 and power >= 6:
				GameManager.spend_power(deity_id, "advance_civ")

	GameManager.end_turn(deity_id)
