# 🪐 Dawn of Worlds: Genesis of Deities (Godot 4 Edition)

[![Godot Engine](https://img.shields.io/badge/Godot-4.3%2B-blue.svg?logo=godot-engine)](https://godotengine.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-emerald.svg)](LICENSE)
[![Genre](https://img.shields.io/badge/Genre-Single--Player%20God%20Simulation-purple.svg)]()
[![Specification](https://img.shields.io/badge/Spec-v2.4%20Master-amber.svg)](GAME_SPECIFICATION.md)

> A faithful, single-player digital god-game simulation directly inspired by John Bobek’s acclaimed 2005 tabletop world-building game *Dawn of Worlds*. Built from the ground up for **Godot 4.3+** using modular GDScript architecture.

---

## 📖 Table of Contents
- [Executive Overview](#-executive-overview)
- [Core Game Loop](#-core-game-loop)
- [The Three Mythological Ages](#-the-three-mythological-ages)
- [Divine Economy & Thrift Bonus](#-divine-economy--thrift-bonus)
- [Canonical Table of Powers](#-canonical-table-of-powers)
- [Spherical Fibonacci Lattice & Biomes](#-spherical-fibonacci-lattice--biomes)
- [Cascading Ripple Rules](#-cascading-ripple-rules)
- [Combat Resolution & Siege Engine](#-combat-resolution--siege-engine)
- [5-Tier Technology Tree](#-5-tier-technology-tree)
- [Apocalyptic Catastrophes & Extinction Rules](#-apocalyptic-catastrophes--extinction-rules)
- [Autonomous NPC Pantheon](#-autonomous-npc-pantheon)
- [Project Architecture & Directory Layout](#-project-architecture--directory-layout)
- [Getting Started & Opening in Godot](#-getting-started--opening-in-godot)
- [Autoload Singletons](#-autoload-singletons)
- [License](#-license)

---

## 🌟 Executive Overview
In **Dawn of Worlds: Genesis of Deities**, the player takes the mantle of a Creator Deity, seated in a celestial council alongside autonomous rival deities. Across three distinct mythological epochs, deities roll $2d6$ power points to sculpt physical topography, weave climate currents, breathe life into sentient races, establish holy and arcane orders, guide civilization breakthroughs across a 5-tier technology tree, wage wars, unleash apocalyptic catastrophes, and transcribe their world's epic history through a historical chronicler.

---

## 🔄 Core Game Loop
1. **Roll Power Points**: At the start of each round, every deity rolls $2d6$ plus their accumulated **Thrift Bonus**.
2. **Determine Turn Order**: Deities act in descending order of their initiative roll for that round.
3. **Execute Divine Powers**: On their turn, deities invoke actions from the canonical **Table of Powers**, spending power points to shape geography, birth races, found orders, research tech, command armies, or weave miracles.
4. **End Turn & Simulate Demographics**: Once the player ends their turn, rival AI deities execute autonomous turns. At the round's conclusion, the world simulates demographic expansion, trade arteries, spontaneous monster emergence (10% default), and army battles.
5. **Epochal Progression**: After 5 rounds of Age 1, the world ascends into the 2nd Age. After 5 rounds of Age 2, it ascends into the 3rd Age (infinite sandbox).

---

## ⏳ The Three Mythological Ages

| Epoch | Epoch Name | Rounds | Scale / Round | Core Focus |
|---|---|---|---|---|
| **Age 1** | First Dawn — Age of Order & Shaping | 5 Rounds | 500 Years | Continental uplift, sea sinking, mountains, biomes, miracles. Sentient races locked. |
| **Age 2** | The Second Age — Awakening of Mortals | 5 Rounds | 100 Years | Synthesize races, cradle cities, subrace adaptations, monster emergence, divine curses. |
| **Age 3** | The Third Age — Era of Empires & Orders | Infinite | 10 Years | Holy/arcane orders, 5-tier tech tree, army clashes, siege warfare, catastrophes, avatars. |

---

## ⚡ Divine Economy & Thrift Bonus
$$\text{Power Gained} = \text{Roll}(2d6) + \text{Thrift Bonus}$$

- **Thrift Rule (Official Dawn of Worlds Rulebook)**: Deities who end their turn with **$5$ or fewer unspent power points** receive a $+1$ Thrift bonus for the following round (capped at $+3$). If a deity ends their turn with $>5$ points, their Thrift bonus resets to $0$.
- **Power Carry-Over**: Unused power points never decay; they accumulate indefinitely to allow saving for major Tier-5 tech or apocalyptic catastrophes.

---

## 📜 Canonical Table of Powers

| Action Key | Action Name | Age 1 Cost | Age 2 Cost | Age 3 Cost | Mechanical Description |
|---|---|---|---|---|---|
| `shape_land` | Shape Climate / Land | **5** | **6** | **8** | Raise mountains, sink oceans, shape plains, forests, volcanic crags, or tundra. |
| `create_race` | Create Sentient Race | *Locked* | **6** | **8** | Synthesize a new intelligent species with cradle sanctuary city & coat of arms. |
| `create_subrace` | Create Subrace / Evolve | *Locked* | **6** | **8** | Adapt an existing species in-place or birth a divergent splinter realm. |
| `curse_race` | Curse / Corrupt Race | *Locked* | **6** | **6** | Malevolent divine curse corrupting an entire race or splintering an evil cult realm. |
| `command_race` | Command Race | *Locked* | **4** | **6** | Direct a race to build a new colony settlement, expanding realm boundaries. |
| `advance_race` | Advance Race / City | *Locked* | **8** | **6** | Impart unique cultural crafts, architectural mastery, or fertility. |
| `advance_civ` | Advance Civ (Tech) | *Locked* | **6** | **4** | Research advancements across 5 tiers (Martial, Agri, Knowledge, Magic, Naval). |
| `command_city` | Command City (Army) | *Locked* | **4** | **3** | Mobilize a grand army host from a city garrison to march or defend. |
| `create_order` | Create Holy / Arcane Order | *Locked* | **6** | **4** | Establish a chivalric chapter, mage cabal, druid circle, or syndicate. |
| `command_order`| Command Order | *Locked* | **3** | **2** | Dispatch orders on sanctified crusades or intelligence maneuvers. |
| `purify_civ` | Purify Civ (+1 Align) | **4** | **3** | **3** | Shift an empire's alignment toward Sacred Virtue (+1 Good). |
| `corrupt_civ` | Corrupt Civ (-1 Align) | **3** | **2** | **2** | Lure an empire toward Abyssal Ambition (-1 Evil). |
| `catastrophe` | Apocalyptic Catastrophe| **10** | **10** | **10** | Unleash Meteor, Supervolcano, Deluge, or Wildfire across 3.8 radial zone. |
| `custom_miracle`| Weave Custom Miracle | **5** | **5** | **5** | Player-engineered divine miracle altering climate, fertility, aura, or boons. |
| `create_avatar`| Create Divine Avatar | **10** | **7** | **8** | Manifest a towering demigod, celestial archon, or high wyrm on the map. |
| `command_avatar`| Command Avatar | **2** | **1** | **1** | Direct avatar to lead hosts in battle or execute divine miracles at zero cost. |

---

## 🌐 Spherical Fibonacci Lattice & Biomes
Rather than a distorted square grid, the world map is modeled as a spherical Fibonacci lattice on an oblate spheroid with 11 distinct terrain types:
- **Submerged**: `deep_ocean` (elevation $\le -0.5$), `ocean` ($-0.5 \dots -0.2$), `shallow_water` ($-0.2 \dots 0.0$).
- **Dry Land**: `plains`, `forest`, `hills`, `mountains`, `swamp`, `desert`, `tundra`, `volcanic`.

---

## 🌊 Cascading Ripple Rules
- **Sink Ocean (2 Stages)**:
  - *Stage 1*: Lowers elevation by $0.28$, creating inland freshwater lakes (`shallow_water`).
  - *Stage 2*: Drops ground zero to $-0.85$ (`deep_ocean`), ring 1 to $-0.55$, ring 2 to coastal shallows.
- **Arid Desert Cascade**: Desiccating winds turn Ring 0-1 to desert, Ring 2 to plains, Ring 3 to forest.
- **Frozen Tundra Cascade**: Freezes plains and forests into tundra while **preserving mountain and hill peaks**.

---

## ⚔️ Combat Resolution & Siege Engine
$$\text{Attacker Score} = \text{Roll}(2d6) + \text{Weapon Tech Bonus} + \text{Racial Bonus} - \text{Fatigue}$$
$$\text{Defender Score} = \text{Roll}(2d6) + \text{Armor Tech Bonus} + \text{Terrain Bonus} + \text{City Walls} + \text{Racial Bonus} - \text{Fatigue}$$

- **Tech Bonuses**: Mithril Warblades ($+5$), Adamantine Armor ($+4$), Tempered Steel ($+3$), Bronze ($+1$), High Wizardry ($+2$).
- **Outcome**:
  - Win by $\ge 5$: Defender army annihilated; city walls demolished, population decimated by $70\%$, city marked `ruined`.
  - Win by $1-4$: Defender army routed; city walls damaged.
  - Defender holds: Attacker repelled with heavy casualties.

---

## 🔬 5-Tier Technology Tree
1. **Martial & Warfare**: T1 Stone Weapons $\to$ T2 Bronze Armaments $\to$ T3 Iron Forging $\to$ T4 Tempered Steel $\to$ T5 Mithril Warblades & Adamantine Armor.
2. **Agriculture & Foodways**: T1 Foraging $\to$ T2 Terraced Canals $\to$ T3 Crop Rotation $\to$ T4 Selective Breeding $\to$ T5 Enchanted Aqueducts & Cornucopias.
3. **Philosophy & Knowledge**: T1 Oral Traditions $\to$ T2 Clay Tablets $\to$ T3 Papyrus Scrolls $\to$ T4 Movable Type $\to$ T5 Grand Scholomance & Orrery.
4. **Arcane & Sacred Arts**: T1 Animist Totems $\to$ T2 Runecraft $\to$ T3 Leyline Tapping $\to$ T4 High Wizardry $\to$ T5 Divine Ascension & Astral Conduits.
5. **Naval & Logistics**: T1 Dugout Canoes $\to$ T2 Lateen Caravels $\to$ T3 Imperial Highways $\to$ T4 Armored Galleons $\to$ T5 Sky-Skiffs & Cloud Harbors.

---

## ☄️ Apocalyptic Catastrophes & Extinction Rules
Disasters impact a **3.8 radial shockwave**:
- **Ring 0–1**: Settlements instantly ruined, population dropped to $\le 15\%$, fortifications wiped out.
- **Ring 2**: Outer cities suffer $70\%$ casualties and wall breaches.
- **Civilization Extinction Check**:
  - If a civilization has **zero active cities outside the disaster zone**, it is **wiped out into extinction**.
  - If it possesses surviving settlements outside the zone, the civilization endures, and its capital automatically relocates to the strongest surviving city.

---

## 👑 Autonomous NPC Pantheon
- **Solaria, Lady of the Dawning Sun**: Benevolent builder, plains, agriculture, sacred virtue.
- **Ignis-Khan, The Pyre Sovereign**: Volcanic warmonger, magma spires, martial races, iron forging.
- **Zephyros, Lord of Roaring Winds**: Tempest shaper, archipelago explorer, naval caravels.
- **Gorgoroth, The World-Breaker**: Destructive titan, earthquakes, mountain crags, goblin raids.
- **Elysia, The Verdant Mother**: Nature weaver, dense forests, druid circles, fertility miracles.
- **Nyxathor, The Void Gazer**: Shadow schemer, corrupts mortal kings, eldritch curses.

---

## 📁 Complete Project Architecture (25 Files)
```
res://
├── project.godot                     # Engine configuration & Autoload registrations
├── icon.svg                          # Game icon asset
├── LICENSE                           # MIT License
├── GAME_SPECIFICATION.md             # Complete v2.4 Master Specification Document
├── scenes/
│   ├── main.tscn                     # Master scene linking Camera, WorldMap, and UI
│   ├── world_map.tscn                # Visual 2D/3D Fibonacci grid renderer
│   └── ui/
│       ├── hud.tscn                  # Top status bar, power counter, turn tracker
│       ├── powers_dock.tscn          # Table of Powers drawer with age gating
│       ├── tech_tree_modal.tscn      # 5-tier breakthrough tree modal
│       └── battle_modal.tscn         # 2d6 battle clash resolution dialog
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd           # Epoch machine, turn flow, power economy, thrift rule
│   │   ├── rules_engine.gd           # Table of Powers costs, 2d6 rolls, action validators
│   │   └── event_bus.gd              # Decoupled signal bus for game events
│   ├── simulation/
│   │   ├── world_grid.gd             # Fibonacci lattice, 11 terrains, cascading ripples
│   │   ├── race.gd                   # Sentient species, traits, physiology, dual-mode evolution
│   │   ├── monstrous_races.gd        # Spontaneous monster emergence (10% roll)
│   │   ├── tech_tree.gd              # 5 categories x 5 tiers with combat & wealth modifiers
│   │   ├── combat_engine.gd          # Battle formula, siege fallout, city ruination
│   │   ├── catastrophe_system.gd     # 3.8 radial shockwave & civilization extinction
│   │   ├── orders.gd                 # Holy/Arcane orders, settlement binding, realm buffs
│   │   ├── heraldry.gd               # Dynamic Coat-of-Arms procedural generator
│   │   ├── geopolitics.gd            # Demographics, trade routes, border expansion
│   │   ├── miracles.gd               # Custom miracle enchantment engine
│   │   └── save_manager.gd           # Auto-save & state serialization
│   ├── ai/
│   │   └── npc_deity_ai.gd           # Autonomous pantheon AI strategic priority trees
│   ├── chronicle/
│   │   └── chronicler.gd             # Multi-age historical event logging & saga formatting
│   └── ui/
│       ├── main_hud.gd               # HUD event binding and feedback animations
│       ├── powers_dock.gd            # Collapsible powers dock UI controller
│       ├── tech_tree_modal.gd        # Interactive tech tree controller
│       └── battle_modal.gd           # Battle clash cinematic modal controller
└── .github/
    └── workflows/
        └── godot-ci.yml              # Headless validation, GDScript linting, export tests
```

---

## 🚀 Getting Started & Opening in Godot

### Prerequisites
- **Godot Engine 4.3 or newer** (Standard version or .NET version). [Download from godotengine.org](https://godotengine.org/download)

### Steps to Open
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/<YOUR_USERNAME>/<YOUR_REPOSITORY_NAME>.git
   cd <YOUR_REPOSITORY_NAME>
   ```
2. **Launch Godot Engine**.
3. In the Project Manager, click **Import**.
4. Browse to the cloned directory and select the `project.godot` file.
5. Click **Import & Edit**.
6. Press **F5** (or click the Play icon in the top right) to run `res://scenes/main.tscn`.

---

## ⚙️ Autoload Singletons
Configured in `project.godot`:
- `EventBus` (`res://scripts/core/event_bus.gd`): Handles global signals like `power_spent`, `epoch_advanced`, `battle_concluded`, and `chronicler_event_logged`.
- `RulesEngine` (`res://scripts/core/rules_engine.gd`): Enforces canonical costs and rule invariants.
- `GameManager` (`res://scripts/core/game_manager.gd`): Controls round state, active deity, and demographics.

---

## 📄 License
This project is open-source under the [MIT License](LICENSE).
Game mechanics inspired by John Bobek's *Dawn of Worlds* (2005).
