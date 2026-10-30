extends Window
## Tech Tree Modal UI Controller (res://scripts/ui/tech_tree_modal.gd)

func research_technology(civ_id: String, category: String, tier: int) -> void:
	EventBus.tech_researched.emit(civ_id, category, tier, "Breakthrough")
