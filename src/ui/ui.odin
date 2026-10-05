package ui

import "src:core"
import "src:log"
import str "src:neb_structures"
import "src:ui/layout"
import rl "vendor:raylib"

@(private)
DEFAULT_UI_ZOOM :: 2.0

@(private)
SCREEN_PADDING :: 8.0 // pixels

UiManager :: struct {
	// layers: str.Stack(Layer),
	state:  StateMap,
	camera: rl.Camera2D,
	size:   rl.Vector2,
}

MakeUiManager :: proc() -> UiManager {
	return {state = make(StateMap), camera = {zoom = DEFAULT_UI_ZOOM}}
}

RegisterComponent :: proc(uiMan: ^UiManager, id: ComponentId, defaultState: State) {
	if _, exists := uiMan.state[id]; exists {
		log.Warn("UI component %+v already registered!", id)
	}
	uiMan.state[id] = defaultState
}

GetState :: proc(uiMan: ^UiManager, id: ComponentId) -> ^State {
	return &uiMan.state[id]
}

Update :: proc(uiMan: ^UiManager) {
	scale := core.GetScreenScale() * DEFAULT_UI_ZOOM

	uiMan.camera.zoom = scale
	uiMan.size = core.GetScreenSize() / scale
}

GetScreen :: proc(uiMan: ^UiManager) -> rl.Rectangle {
	return layout.Padding(core.MakeRect({0, 0}, uiMan.size), SCREEN_PADDING)
}

Shutdown :: proc(uiMan: ^UiManager) {
	delete(uiMan.state)
}
