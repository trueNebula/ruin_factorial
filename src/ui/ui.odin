package ui

import "src:log"
import str "src:neb_structures"
import rl "vendor:raylib"

UiManager :: struct {
	layers: str.Stack(Layer),
	state:  StateMap,
	camera: rl.Camera2D,
}

MakeUiManager :: proc() -> UiManager {
	return {state = make(StateMap), camera = {zoom = 4.0}}
}

RegisterComponent :: proc(uiMan: ^UiManager, id: ComponentId, defaultState: State) {
	if _, exists := uiMan.state[id]; exists {
		log.Warn("Component %+v already registered!", id)
	}
	uiMan.state[id] = defaultState
}

GetState :: proc(uiMan: ^UiManager, id: ComponentId) -> ^State {
	return &uiMan.state[id]
}

Shutdown :: proc(uiMan: ^UiManager) {
	delete(uiMan.state)
}
