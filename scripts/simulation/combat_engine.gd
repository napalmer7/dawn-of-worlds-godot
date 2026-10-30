extends Node
## Combat Resolution Engine (res://scripts/simulation/combat_engine.gd)
## Formula: Attacker (2d6 + Tech + Racial - Fatigue) vs Defender (2d6 + Tech + Walls + Terrain - Fatigue)

func resolve_battle(attacker: Dictionary, defender: Dictionary, location_cell: Dictionary) -> Dictionary:
	var att_dice = RulesEngine.roll_2d6()
	var def_dice = RulesEngine.roll_2d6()

	var att_tech = attacker.get("tech_bonus", 0)
	var att_racial = attacker.get("racial_bonus", 0)
	var att_fatigue = attacker.get("fatigue", 0)
	var att_total = att_dice["total"] + att_tech + att_racial - att_fatigue

	var def_tech = defender.get("tech_bonus", 0)
	var def_racial = defender.get("racial_bonus", 0)
	var def_walls = defender.get("wall_defense", 0)
	var def_terrain = 1 if (location_cell["terrain"] in ["mountains", "hills"]) else 0
	var def_fatigue = defender.get("fatigue", 0)
	var def_total = def_dice["total"] + def_tech + def_racial + def_walls + def_terrain - def_fatigue

	var margin = att_total - def_total
	var outcome = ""
	var city_ruined = false
	var wall_damage = 0

	if margin >= 5:
		outcome = "DECISIVE_VICTORY"
		city_ruined = true
		wall_damage = 3
	elif margin >= 1:
		outcome = "MARGINAL_VICTORY"
		wall_damage = 1
	else:
		outcome = "DEFENDER_HOLDS"

	var report = {
		"attacker_total": att_total,
		"defender_total": def_total,
		"margin": margin,
		"outcome": outcome,
		"city_ruined": city_ruined,
		"wall_damage": wall_damage,
		"location_index": location_cell["index"]
	}

	EventBus.battle_resolved.emit(report)
	return report
