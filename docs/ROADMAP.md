# Dawn of Worlds development roadmap

Updated November 12, 2026.

The Godot game is a partial port of the original TypeScript game. Use the original application and source as references for established interactions and visual hierarchy, alongside GAME_SPECIFICATION.md. Resolve differences between implemented rules and the specification explicitly rather than assuming they agree.

References:
- Original application: https://aistudio.google.com/apps/a28c40d9-021e-4add-9c33-01bbf0c6d841?showPreview=true&showAssistant=true
- Original source: https://github.com/napalmer7/divine_simulator
- Game specification: ../GAME_SPECIFICATION.md

## Completed: startup and saved sessions

- [x] Dedicated start menu with New Game, Load Game, Continue, and Settings placeholder.
- [x] Initialize round 1 explicitly and guard actions by active turn.
- [x] Independent world saves, automatic saving, and resume without rerolling or advancing time.
- [x] In-game Save and Return to Menu controls.

## Next: rebuild and polish the gameplay interface

Status: planned; implementation has not started. This is an explicit milestone, brought forward before further civilization controls are added.

Goal: bring the Godot gameplay screen up to the visual quality and interaction clarity of the TypeScript version, with a consistent style across the start menu and game components. Preserve the successful start-menu direction while extending it into gameplay.

### Layout and shared visual style

- [ ] Compare the original gameplay screen and component states directly; capture references and propose a Godot layout before rebuilding.
- [ ] Establish shared colors, typography, spacing, icons, panels, buttons, tooltips, focus styles, and feedback states.
- [ ] Replace default gray Godot styling throughout the gameplay screen with the established dark celestial/cartographic direction.
- [ ] Rebuild the layout using containers and a dedicated map viewport. The powers dock must not overlap or obscure the atlas, its status bar, or its legend.
- [ ] Adapt to window resizing with sensible minimum sizes, scrolling, and a collapsible powers drawer.

### Gameplay components

- [ ] Rebuild the top bar: world, age, round/year, deity/turn, power/dice/thrift, and End Turn.
- [ ] Rebuild the powers dock: category tabs, terrain/climate sections, scope selection, selected targets, action costs, affordability, age locks, and active states.
- [ ] Make displayed costs agree with actual deductions. Resolve TypeScript/specification cost differences before implementing dynamic pricing.
- [ ] Improve atlas presentation: terrain palette, grid, resources, selected/hovered cells, readable survey information, and a clear legend.
- [ ] Integrate Save and Return to Menu into the shared navigation style, with unobtrusive success messages and clear errors.
- [ ] Apply the same design system to Load Game and future race/civilization, technology, battle, pantheon, and chronicle screens as those systems become available.
- [ ] Keep unavailable features clearly labeled or disabled; active-looking buttons must perform their stated action.
- [ ] Add restrained transitions and feedback for selection, invoking powers, turn changes, saving, and invalid actions.

### Acceptance criteria

- [ ] At 1280×720, the atlas, powers dock, navigation, survey details, and legend are readable and do not overlap.
- [ ] Resizing to a smaller window or a wide display keeps essential actions accessible without clipped controls or text.
- [ ] Mouse selection still targets the correct world cells after resizing or collapsing the drawer.
- [ ] Keyboard focus stays visible, including inside scrolling panels.
- [ ] Every power shows its real cost and why it is unavailable when locked or unaffordable.
- [ ] Starting, loading, saving, and resuming continue to pass session regression checks.
- [ ] Review rendered screens against the original TypeScript reference and obtain feedback on the visual result.

## Following: playable civilization loop

- [ ] Create a sentient race, its civilization, and a cradle city from the interface.
- [ ] Persist entity ownership and relationships in the save schema.
- [ ] Connect population growth and settlement expansion to round completion.
- [ ] Make NPC actions produce visible world changes.
- [ ] Connect technology research and its effects.

## Later: conflict, divine systems, and graphical expansion

- [ ] Armies, movement, combat consequences, and battle presentation.
- [ ] Catastrophes, extinction, and capital relocation.
- [ ] Orders, miracles, avatars, and race evolution.
- [ ] Pantheon relationships and richer chronicles.
- [ ] Map overlays and 3D globe presentation, using the same underlying world state.

The interface milestone improves the current atlas and component foundation. A 3D globe and richer world rendering remain separate deliverables so visual polish and simulation completeness can be evaluated independently.
