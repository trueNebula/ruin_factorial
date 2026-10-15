package ui

import "core:math"
import "src:core"
import "src:log"
import str "src:neb_structures"
import "src:ui/layout"
import rl "vendor:raylib"

@(private)
SCREEN_PADDING :: 8.0 // pixels

UiManager :: struct {
	// layers: str.Stack(Layer),
	state:  StateMap,
	camera: rl.Camera2D,
	size:   rl.Vector2,
}

MakeUiManager :: proc() -> UiManager {
	return {state = make(StateMap), camera = {zoom = 1}}
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
	zoom := core.GetUiZoom()
	uiMan.camera.zoom = zoom
	uiMan.size = {
		math.floor(f32(rl.GetScreenWidth()) / zoom),
		math.floor(f32(rl.GetScreenHeight()) / zoom),
	}
}

GetScreen :: proc(uiMan: ^UiManager) -> rl.Rectangle {
	return layout.Padding(core.MakeRect({0, 0}, uiMan.size), SCREEN_PADDING)
}

Shutdown :: proc(uiMan: ^UiManager) {
	delete(uiMan.state)
}
