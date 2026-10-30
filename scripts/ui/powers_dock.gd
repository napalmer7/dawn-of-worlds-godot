extends PanelContainer
## Powers Dock Drawer Controller (res://scripts/ui/powers_dock.gd)

func invoke_power(action_key: String) -> void:
	var current_age = GameManager.current_age
	var cost = RulesEngine.get_power_cost(action_key, current_age)
	if GameManager.spend_power("player_deity", action_key):
		print("Invoked power: ", action_key, " (-", cost, " pts)")
	else:
		print("Insufficient power for ", action_key)
