extends Node
## 5-Tier Technology Tree System (res://scripts/simulation/tech_tree.gd)
## Implements the full DEFAULT_TECH_TREE from the specification across all 5 branches.

const CATEGORIES = {
	"martial": {
		"name": "Martial & Warfare",
		"tiers": [
			{ "tier": 1, "name": "Stone Weapons & Wooden Clubs", "cost": 0, "atk": 0, "def": 0 },
			{ "tier": 2, "name": "Bronze Armaments & Tower Shields", "cost": 4, "atk": 1, "def": 1 },
			{ "tier": 3, "name": "Iron Forging & Heavy Cavalry", "cost": 6, "atk": 2, "def": 1 },
			{ "tier": 4, "name": "Tempered Steel & Siege Engines", "cost": 8, "atk": 3, "def": 2 },
			{ "tier": 5, "name": "Mithril Warblades & Adamantine Armor", "cost": 10, "atk": 5, "def": 4 }
		]
	},
	"agriculture": {
		"name": "Agriculture & Foodways",
		"tiers": [
			{ "tier": 1, "name": "Foraging & Wild Grain Harvesters", "cost": 0, "pop_mod": 1.0 },
			{ "tier": 2, "name": "Terraced Canals & Silos", "cost": 4, "pop_mod": 1.1 },
			{ "tier": 3, "name": "Crop Rotation & Heavy Iron Plows", "cost": 6, "pop_mod": 1.2 },
			{ "tier": 4, "name": "Selective Breeding & Windmills", "cost": 8, "pop_mod": 1.3 },
			{ "tier": 5, "name": "Enchanted Aqueducts & Cornucopias", "cost": 10, "pop_mod": 1.5 }
		]
	},
	"philosophy": {
		"name": "Philosophy & Knowledge",
		"tiers": [
			{ "tier": 1, "name": "Oral Traditions & Elder Chants", "cost": 0, "wealth": 0 },
			{ "tier": 2, "name": "Clay Tablets & Pictographic Glyphs", "cost": 4, "wealth": 5 },
			{ "tier": 3, "name": "Papyrus Scrolls & Monastic Scriptor", "cost": 6, "wealth": 15 },
			{ "tier": 4, "name": "Movable Type Printing & Academies", "cost": 8, "wealth": 30 },
			{ "tier": 5, "name": "Grand Scholomance & Clockwork Orrery", "cost": 10, "wealth": 60 }
		]
	},
	"arcane": {
		"name": "Arcane & Sacred Arts",
		"tiers": [
			{ "tier": 1, "name": "Animist Totems & Spirit Whispers", "cost": 0, "def": 0 },
			{ "tier": 2, "name": "Elemental Runecraft & Warding Stones", "cost": 4, "def": 1 },
			{ "tier": 3, "name": "Leyline Tapping & Arcanist Spires", "cost": 6, "mana": 2 },
			{ "tier": 4, "name": "High Wizardry & Abjurations", "cost": 8, "atk": 2 },
			{ "tier": 5, "name": "Divine Ascension & Astral Conduits", "cost": 10, "atk": 4, "def": 3 }
		]
	},
	"naval": {
		"name": "Naval & Logistics",
		"tiers": [
			{ "tier": 1, "name": "Dugout Canoes & Coastal Rafts", "cost": 0, "range": 1 },
			{ "tier": 2, "name": "Lateen Caravels & Wayfinding Stars", "cost": 4, "range": 2 },
			{ "tier": 3, "name": "Paved Imperial Highways & Outposts", "cost": 6, "range": 3 },
			{ "tier": 4, "name": "Armored Galleons & Maritime Cannons", "cost": 8, "range": 4, "atk": 1 },
			{ "tier": 5, "name": "Sky-Skiffs & Cloud Harbors", "cost": 10, "range": 99 }
		]
	}
}

func get_combat_tech_bonus(researched_tiers: Dictionary) -> Dictionary:
	var martial_tier = researched_tiers.get("martial", 1)
	var arcane_tier = researched_tiers.get("arcane", 1)
	var naval_tier = researched_tiers.get("naval", 1)

	var atk = 0
	var def = 0

	match martial_tier:
		5: atk += 5; def += 4
		4: atk += 3; def += 2
		3: atk += 2; def += 1
		2: atk += 1; def += 1

	if arcane_tier >= 5:
		atk += 4; def += 3
	elif arcane_tier >= 4:
		atk += 2
	elif arcane_tier >= 2:
		def += 1

	if naval_tier >= 4:
		atk += 1

	return { "atk": atk, "def": def }
