extends RefCounted
## Dynamic Heraldry Generator (res://scripts/simulation/heraldry.gd)
## Generates procedural SVG coat-of-arms with historical heraldic tinctures and charges.

const TINCTURES = ["Or", "Argent", "Gules", "Azure", "Vert", "Sable", "Purpure"]
const CHARGES = ["Wyvern", "Radiant Sun", "Anvil", "Elder Oak", "Obsidian Eye", "Crossed Swords"]

static func generate_arms_for_civ(civ_name: String) -> Dictionary:
	var seed_val = civ_name.hash()
	var tincture1 = TINCTURES[abs(seed_val) % TINCTURES.size()]
	var tincture2 = TINCTURES[abs(seed_val / 7) % TINCTURES.size()]
	var charge = CHARGES[abs(seed_val / 49) % CHARGES.size()]

	return {
		"field": tincture1,
		"secondary": tincture2,
		"charge": charge,
		"blazon": charge + " on field " + tincture1
	}
