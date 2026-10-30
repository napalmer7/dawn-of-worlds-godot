extends Node
## Holy & Arcane Orders Conclave (res://scripts/simulation/orders.gd)
## Binds chivalric, monastic, and arcane orders to active settlements for realm-wide buffs.

const ORDER_TYPES = {
	"knightly": { "name": "Knightly Chapter", "wall_bonus": 2, "army_bonus": 1 },
	"religious": { "name": "Holy Monastic Order", "faith_bonus": 1, "shrine": true },
	"arcane": { "name": "College of Wizardry", "tech_speed": 0.25, "renown": 15 },
	"druidic": { "name": "Circle of Elders", "agri_bonus": 0.30, "wealth": 35 }
}

func establish_order(city_id: String, order_type: String, order_name: String) -> Dictionary:
	var def = ORDER_TYPES.get(order_type, ORDER_TYPES["knightly"])
	var order_data = {
		"id": "order_" + str(randi()),
		"name": order_name,
		"city_id": city_id,
		"type": order_type,
		"wall_bonus": def.get("wall_bonus", 0),
		"army_bonus": def.get("army_bonus", 0)
	}
	EventBus.order_established.emit(order_data)
	return order_data
