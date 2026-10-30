# Dawn of Worlds: Genesis of Deities
## Comprehensive Game Design & Technical Specification Document
*Version 2.4 — Master Reference for Faithful Re-creation*

---

## 1. Executive Summary & Core Concept

**Dawn of Worlds: Genesis of Deities** is an interactive, digital god-game simulation directly inspired by John Bobek’s acclaimed 2005 tabletop world-building game *Dawn of Worlds*. 

The application transforms the turn-based tabletop system into a living, visual simulation. Players assume the mantle of a Creator Deity, seated in a celestial council alongside autonomous rival deities. Across three distinct mythological epochs (Ages), deities spend celestial power points to sculpt physical topography, weave climate currents, breathe life into sentient races, establish holy and arcane orders, guide civilization breakthroughs across a 5-tier technology tree, wage wars, unleash apocalyptic catastrophes, and transcribe their world's epic history through an AI-powered chronicler.

### Primary Game Loop
1. **Roll Power Points**: Each round, every deity rolls 2d6 plus accumulated Thrift bonus (rewarding deities who conserve energy).
2. **Determine Turn Order**: Deities act in descending order of their initiative roll for that round.
3. **Execute Divine Powers**: On their turn, deities invoke actions from the canonical **Table of Powers**, spending power points to shape the world or guide mortals.
4. **End Turn & Simulate Demographics**: Once the player ends their turn, rival AI deities execute autonomous turns. At the conclusion of the round, the world advances by an epoch of years, simulating demographic growth, territorial expansion, trade artery generation, spontaneous monster emergence, and army battles.
5. **Epochal Progression**: After 5 rounds in the 1st Age, the world ascends into the 2nd Age. After 5 rounds and the emergence of active civilizations, it ascends into the 3rd Age.

---

## 2. Divine Economy & The Table of Powers

### 2.1 Power Point Generation & Thrift Bonus
Power is the universal currency of the deities. At the beginning of each round:
Power Gained = Roll(2d6) + Thrift Bonus

- **Thrift Rule (Official Dawn of Worlds Rulebook)**: Deities who end their turn with 5 or fewer unspent power points are rewarded with frugality. Their Thrift bonus increases by +1 (up to a maximum cap of +3). If a deity ends their turn with more than 5 points, their Thrift bonus resets to 0.
- **Power Accumulation**: Deities do not lose unused power at the end of a round; it carries over indefinitely, enabling hoarding for massive apocalyptic interventions or Tier-5 breakthroughs.

### 2.2 Canonical Table of Powers (Cost by Age)

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

## 3. World Representation & Topographical Simulation

### 3.1 Spherical Fibonacci Lattice Grid
Modeled as a spherical Fibonacci lattice on an oblate spheroid. Distance between cells computed via the Great-Circle Haversine approximation.

### 3.2 Cell State & 11 Terrains
Submerged: `deep_ocean`, `ocean`, `shallow_water`.
Dry Land: `plains`, `forest`, `hills`, `mountains`, `swamp`, `desert`, `tundra`, `volcanic`.

### 3.3 Cascading Ripple Rules
- **Sink Ocean (2 Stages)**: Stage 1 drops 0.28 elevation (freshwater lake `shallow_water`). Stage 2 drops ground zero to -0.85 (`deep_ocean`), ring 1 to -0.55 (`ocean`), ring 2 to coastal shallows.
- **Arid Desert Cascade**: Ring 0-1 desert, Ring 2 plains, Ring 3 forest.
- **Frozen Tundra Cascade**: Invariant: Mountain & hill peaks are preserved.

---

## 4. Races, Civilizations & Geopolitics
- **Sentient Race Synthesis**: Demonym, traits, anatomical attributes (skin, stature, limbs, lifespan, metabolism), alignment (-1 to +1), military bonus.
- **Spontaneous Monster Emergence**: 10% default roll per round in Age 2 (Goblins in mountains/forests, Kobolds in volcanoes, Dragons in calderas, Troglodytes in swamps).
- **Dual-Mode Race Evolution**:
  - Mode A: Evolve Original Race In-Place (Universal ascension, empire preserves unity).
  - Mode B: Create Derived Subrace (Branches divergent lineage into splinter realm).

---

## 5. Technology Tree (5 Tiers)
1. Martial & Warfare: T1 Stone -> T2 Bronze (+1 War/+1 Df) -> T3 Iron (+2 War/+1 Df) -> T4 Steel (+3 War/+2 Df) -> T5 Mithril (+5 War/+4 Df).
2. Agriculture & Foodways: T1 Foraging -> T2 Canals (+10%) -> T3 Crop Rotation (+20%) -> T4 Breeding (+30%) -> T5 Enchanted Aqueducts (+50%).
3. Philosophy & Knowledge: T1 Oral -> T2 Clay (+5g) -> T3 Scrolls (+15g) -> T4 Printing (+30g) -> T5 Scholomance (+60g).
4. Arcane & Sacred Arts: T1 Totems -> T2 Runecraft (+1 Df) -> T3 Leylines -> T4 High Wizardry (+2 Atk) -> T5 Ascension (+4 Atk/+3 Df).
5. Naval & Logistics: T1 Dugouts -> T2 Caravels -> T3 Highways -> T4 Galleons (+1 Atk) -> T5 Sky-Skiffs.

---

## 6. Combat & Catastrophes
- Combat Formula: Attacker (2d6 + Tech + Racial - Fatigue) vs Defender (2d6 + Tech + Terrain + Walls + Racial - Fatigue).
- Margin >= 5: Attacker Decisive Victory (Defender destroyed, walls leveled, pop decimated by 70%, city ruined).
- Margin 1-4: Marginal Victory (Walls damaged).
- Catastrophes: 3.8 radial blast zone. Core cities ruined. Civilization extinguished if 0 active cities survive outside the zone; else capital relocates.

---

## 7. Autonomous NPC Deities
- Solaria (Sun & Virtue), Ignis-Khan (Volcanoes & Martial), Zephyros (Winds & Seafaring), Gorgoroth (Earthquakes & Raids), Elysia (Verdant Nature), Nyxathor (Shadow & Curses).
