package input

import "src:core"
import rl "vendor:raylib"

State :: struct {
	actionPressed: bit_set[core.InputAction],
	actionHeld:    bit_set[core.InputAction],
	mousePos:      rl.Vector2,
	mousePressed:  bit_set[core.MouseButton],
	mouseHeld:     bit_set[core.MouseButton],
	mouseConsumed: bit_set[core.MouseButton],
}

Poll :: proc(binds: core.Keybinds) -> State {
	state: State

	// TODO: use keybinds
	if rl.IsKeyPressed(binds.Up) do state.actionPressed += {.UP}
	if rl.IsKeyPressed(binds.Down) do state.actionPressed += {.DOWN}
	if rl.IsKeyPressed(binds.Left) do state.actionPressed += {.LEFT}
	if rl.IsKeyPressed(binds.Right) do state.actionPressed += {.RIGHT}
	if rl.IsKeyPressed(binds.Inventory) do state.actionPressed += {.INVENTORY}
	if rl.IsKeyPressed(binds.Menu) do state.actionPressed += {.MENU}

	if rl.IsKeyDown(binds.Up) do state.actionHeld += {.UP}
	if rl.IsKeyDown(binds.Down) do state.actionHeld += {.DOWN}
	if rl.IsKeyDown(binds.Left) do state.actionHeld += {.LEFT}
	if rl.IsKeyDown(binds.Right) do state.actionHeld += {.RIGHT}
	if rl.IsKeyDown(binds.Inventory) do state.actionHeld += {.INVENTORY}
	if rl.IsKeyDown(binds.Menu) do state.actionHeld += {.MENU}

	state.mousePos = rl.GetMousePosition()

	if rl.IsMouseButtonDown(binds.Action) do state.mouseHeld += {.LEFT}
	if rl.IsMouseButtonDown(binds.Interact) do state.mouseHeld += {.RIGHT}
	if rl.IsMouseButtonPressed(binds.Action) do state.mousePressed += {.LEFT}
	if rl.IsMouseButtonPressed(binds.Interact) do state.mousePressed += {.RIGHT}

	return state
}

MaybeConsumeMouse :: proc(state: ^State, button: core.MouseButton) -> (consumed: bool) {
	if button not_in state.mouseHeld do return false
	if button in state.mouseConsumed do return false
	state.mouseConsumed += {button}
	return true
}
