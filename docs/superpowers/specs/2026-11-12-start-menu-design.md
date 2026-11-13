# Start menu and session startup

Status: approved by the user on November 12, 2026.

## Purpose

Make the start menu the game's entry point and give new and returning players a reliable way into a world. This is the first step toward the agreed playable gameplay loop.

## Player experience

- The launch screen displays the game title and New Game, Load Game, Continue, and Settings.
- New Game creates a fresh world with the existing default pantheon and map. World customization is deferred. Existing saves are retained.
- Load Game opens a list of saved worlds with their last-played time, age, round, and year. Choosing one restores that session.
- Continue resumes the most recently played saved world. It is disabled with an explanation when no usable save exists.
- Settings is visibly marked Coming soon and disabled.
- In-game Save and Return to Menu controls make saved sessions available without restarting the app. Return to Menu saves successfully before leaving; a save failure keeps the player in the game and shows an error.
- Completed player turns are saved automatically so Continue has a recent checkpoint. New games are saved once their initial playable turn is ready.
- A corrupt or incompatible save shows an understandable error without modifying other saves or launching a partial session.

## Startup and persistence

The menu does not initialize a live game or advance simulation. New Game loads the gameplay scene, waits for the world, HUD, AI, and chronicler to be ready, then initializes round 1 exactly once. Use the existing 2d6 initiative and power rules; do not change balance in this feature. NPC turns before the player's turn complete normally.

Loading restores world cells, selection and shaping scope, deity power/thrift, age/round/year, initiative order and active turn, and chronicle history. It does not roll power or advance time. Colors must survive serialization. Use versioned save records and validate input before replacing live state. All currently persistent gameplay data must round-trip; future entity systems will extend the save schema when introduced.

Only the active deity may spend power or end a turn. Menu state cannot accept gameplay actions. The HUD reads actual state on entry and reflects whether the player can act.

## Approaches

Recommended: a dedicated menu scene with explicit new/load session entry and a shared save service. It reuses the existing gameplay scene and isolates startup from ordinary turn progression.

Alternative: place a menu overlay over an already running world. This requires suppressing simulation behind the overlay and makes accidental initialization and extra rolls harder to prevent.

Alternative: add menu buttons first and defer persistence. This would leave Load and Continue unable to fulfill their labels.

## Presentation and constraints

Use Godot-native controls, keyboard focus, responsive containers, and the existing dark atlas/gold visual direction. No new dependencies or generated art are required. Preserve existing project configuration edits and unrelated game behavior. Keep Settings as a placeholder.

## Acceptance checks

1. Launch shows the menu and leaves the simulation inactive.
2. With no saves, Continue is disabled and Load explains the empty state.
3. New Game reaches a valid player turn in round 1; the first End Turn does not skip an uninitialized round.
4. Shape terrain, end a turn, save, return to menu, and Continue: cells, power, history, and time match the checkpoint without another roll.
5. Create two games and load each independently; Continue follows last played rather than creation order.
6. Missing, malformed, incompatible, and unwritable saves produce clear feedback and preserve the current session.
7. Settings remains clearly unavailable; menu and load selection work with keyboard and mouse.
