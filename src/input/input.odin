package input

import "src:core"
import "src:ecs"
import rl "vendor:raylib"

State :: struct {
	actionPressed: bit_set[core.InputAction],
	actionHeld:    bit_set[core.InputAction],
	mousePos:      rl.Vector2,
	mousePressed:  bit_set[core.MouseButton],
	mouseHeld:     bit_set[core.MouseButton],
	mouseConsumed: bit_set[core.MouseButton],
}

Poll :: proc() -> State {
	state: State

	// TODO: use keybinds
	if rl.IsKeyPressed(.W) do state.actionPressed += {.UP}
	if rl.IsKeyPressed(.S) do state.actionPressed += {.DOWN}
	if rl.IsKeyPressed(.A) do state.actionPressed += {.LEFT}
	if rl.IsKeyPressed(.D) do state.actionPressed += {.RIGHT}
	if rl.IsKeyPressed(.E) do state.actionPressed += {.INVENTORY}
	if rl.IsKeyPressed(.ESCAPE) do state.actionPressed += {.MENU}

	if rl.IsKeyDown(.W) do state.actionHeld += {.UP}
	if rl.IsKeyDown(.S) do state.actionHeld += {.DOWN}
	if rl.IsKeyDown(.A) do state.actionHeld += {.LEFT}
	if rl.IsKeyDown(.D) do state.actionHeld += {.RIGHT}
	if rl.IsKeyDown(.E) do state.actionHeld += {.INVENTORY}
	if rl.IsKeyDown(.ESCAPE) do state.actionHeld += {.MENU}

	state.mousePos = rl.GetMousePosition()

	if rl.IsMouseButtonDown(.LEFT) do state.mouseHeld += {.LEFT}
	if rl.IsMouseButtonDown(.RIGHT) do state.mouseHeld += {.RIGHT}
	if rl.IsMouseButtonPressed(.LEFT) do state.mousePressed += {.LEFT}
	if rl.IsMouseButtonPressed(.RIGHT) do state.mousePressed += {.RIGHT}

	return state
}

MaybeConsumeMouse :: proc(state: ^State, button: core.MouseButton) -> (consumed: bool) {
	if button not_in state.mouseHeld do return false
	if button in state.mouseConsumed do return false
	state.mouseConsumed += {button}
	return true
}
