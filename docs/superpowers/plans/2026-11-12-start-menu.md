# Start Menu Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Goal:** Launch into a menu, start round 1 correctly, and save/resume multiple worlds.

**Architecture:** Dedicated menu and gameplay scenes; SaveManager owns versioned files and validation; SessionController owns scene transitions and snapshots. GameManager owns reset and turn guards. Existing atlas and chronicle remain the gameplay state.

**Tech Stack:** Godot 4.7.2, GDScript, native controls and JSON.

**Spec:** ../specs/2026-11-12-start-menu-design.md

## Global Constraints

- Keep Settings as a placeholder.
- Preserve existing project configuration edits and unrelated game behavior.
- No new dependencies or generated art are required.

## Review Focus

- No saves, malformed saves, incompatible versions, and unwritable storage.
- Returning to menu and re-entering must not duplicate initialization or signal listeners.
- Loading must preserve powers, selected cells, initiative and time without another roll.
- Two worlds remain independent; Continue follows last played.
- Keyboard navigation and small window layouts remain usable.

## Task 1: Session startup and persistence

Files: scripts/core/game_manager.gd, scripts/core/session_controller.gd, scripts/core/gameplay.gd, scripts/simulation/save_manager.gd, scenes/main.tscn, tests/test_sessions.gd.

Interfaces: SaveManager.save_world_state(state: Dictionary) -> bool, load_world_state(id: String) -> Dictionary, list_saved_games() -> Array[Dictionary]; SessionController.new_game(), load_game(id: String) -> bool, save_current_game() -> bool, return_to_menu() -> bool; GameManager.reset_game(), is_deity_turn(id: String) -> bool.

- [x] Write/run a headless test showing menu entry, valid round-1 startup, inactive/wrong-deity rejection, save round-trip, corrupt input rejection and independent worlds. Verify failure before implementation.
- [x] Implement validated versioned snapshots, safe replacement, reset/turn guards and scene entry. Autosave only at stable player turns.
- [x] Run headless tests; check exact power/time/map/history restoration and save failure behavior.

## Task 2: Menu and gameplay controls

Files: scenes/start_menu.tscn, scripts/ui/start_menu.gd, scripts/ui/main_hud.gd, project.godot, README.md, tests/test_sessions.gd.

- [x] Extend/run tests for main-scene configuration, empty/valid save menu states, Settings placeholder and actual button navigation.
- [x] Implement a dark/gold responsive menu, save list, error feedback, Save and Return to Menu controls; initialize HUD from live state.
- [x] Run full headless suite, editor import and runtime checks; visually inspect menu and gameplay. Record results and review final changes.

## Execution notes

User approved implementation in the current workspace; preserve their existing project.godot edits. Leave changes uncommitted for review. Use isolated test storage so tests never touch personal saves.

## Verification and review record

- Initial tests failed on missing menu/session services and reset; implemented and reran successfully.
- Save/load uses full-precision JSON. Decimal parsing may vary the last binary digit of coordinates; tests allow less than 1e-12 difference for floats and require exact integer power/time/turn values.
- Rendered menu, gameplay controls, and load list with Godot's OpenGL renderer and inspected screenshots.
- Independent review traced startup, save failures, malformed input, scene transitions, and snapshot restoration. Its keyboard scrolling finding and a stable-world-label finding were reproduced with failing checks and fixed.
- Editor import loaded all scripts/scenes, but reported an environment permissions error saving editor settings. Runtime checks are separate from editor settings and pass.
- Existing terrain costs, simulation gaps, and atlas/HUD overlap are outside this menu feature and remain for the next gameplay milestone.
