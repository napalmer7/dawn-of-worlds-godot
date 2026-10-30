extends RefCounted
## Sentient Race & Demographics Model (res://scripts/simulation/race.gd)
## Governs anatomy, traits, alignment, and dual-mode evolution pathways.

var id: String = ""
var name: String = ""
var demonym: String = ""
var creator_deity_id: String = ""
var traits: Array[String] = []
var carapace_or_skin: String = "Normal"
var stature: String = "Medium"
var limbs: String = "Bipedal"
var lifespan_years: int = 80
var metabolism: String = "Warm-blooded"
var intelligence_level: String = "Scholastic"
var societal_behavior: String = "Feudal"
var base_alignment: int = 0
var military_bonus: int = 0
var procreation_rate: float = 1.0
var evolved_from_id: String = ""

func evolve_in_place(new_name: String, stat_boons: Dictionary) -> void:
	name = new_name
	military_bonus += stat_boons.get("military_bonus", 1)
	if stat_boons.has("traits"):
		traits.append_array(stat_boons["traits"])
