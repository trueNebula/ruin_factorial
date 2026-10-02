package ui

import "src:log"
import str "src:neb_structures"

UiManager :: struct {
	layers: str.Stack(Layer),
	state:  StateMap,
}

MakeUiManager :: proc() -> UiManager {
	return {state = make(StateMap)}
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
