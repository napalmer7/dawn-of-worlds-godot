extends Node
## Global EventBus Singleton (res://scripts/core/event_bus.gd)
## Decouples simulation logic, rules enforcement, UI interactions, and chronicler logging.

# --- Turn & Epoch Signals ---
signal round_started(round_number: int, age: int, year: int)
signal deity_turn_started(deity_id: String)
signal deity_power_changed(deity_id: String, new_power: int, delta: int)
signal deity_turn_ended(deity_id: String)
signal round_ended(round_number: int, age: int)
signal epoch_advanced(new_age: int, age_name: String)

# --- World & Shaping Signals ---
signal cell_terrain_shaped(cell_index: int, new_terrain: String, elevation: float)
signal miracle_woven(cell_index: int, miracle_type: String, duration_rounds: int)
signal catastrophe_unleashed(epicenter_index: int, disaster_type: String, ruined_cities: Array)

# --- Civilizations & Races Signals ---
signal race_created(race_data: Dictionary)
signal subrace_evolved(ancestor_id: String, new_race_data: Dictionary, is_in_place: bool)
signal race_corrupted(race_id: String, alignment_delta: int)
signal city_founded(city_data: Dictionary)
signal order_established(order_data: Dictionary)
signal tech_researched(civ_id: String, category: String, tier: int, tech_name: String)

# --- Conflicts & Armies Signals ---
signal army_mobilized(city_id: String, civ_id: String, cell_index: int)
signal army_moved(army_id: String, from_cell: int, to_cell: int)
signal battle_resolved(battle_report: Dictionary)
signal civilization_extinguished(civ_id: String, reason: String)

# --- Chronicle & Logging Signals ---
signal chronicle_entry_logged(entry: Dictionary)
