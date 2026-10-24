package ui

import "core:math"
import "src:core"
import "src:log"
import "src:render"
import "src:texture"
import "src:ui/layout"
import rl "vendor:raylib"

@(private)
SCREEN_PADDING :: 8.0 // pixels

@(private)
MAX_FRAME_CNT :: 2_147_483_647

@(private)
SCRIM :: rl.Color{0, 0, 0, 127}

UiManager :: struct {
	size:                     rl.Vector2,
	camera, worldCamera:      rl.Camera2D,
	nodes:                    [dynamic]Node,
	parents:                  [dynamic]int,
	widgets:                  map[Id]WidgetState,
	hovered, active, clicked: Id,
	mouse:                    [Space]rl.Vector2,
	menuOpen:                 bool,
	textFieldActive:          bool,
	frame:                    int,
}

MakeUiManager :: proc() -> UiManager {
	nodes := make([dynamic]Node)
	parents := make([dynamic]int)
	widgets := make(map[Id]WidgetState)
	return {nodes = nodes, parents = parents, widgets = widgets, camera = rl.Camera2D{zoom = 1}}
}

Update :: proc(uiMan: ^UiManager) {
	zoom := core.GetUiZoom()
	uiMan.camera.zoom = zoom
	uiMan.size = {
		math.floor(f32(rl.GetScreenWidth()) / zoom),
		math.floor(f32(rl.GetScreenHeight()) / zoom),
	}
}

GetScreen :: proc(uiMan: ^UiManager, padding: f32 = SCREEN_PADDING) -> rl.Rectangle {
	return layout.Padding(core.MakeRect({0, 0}, uiMan.size), padding)
}

Shutdown :: proc(uiMan: ^UiManager) {
	delete(uiMan.nodes)
	delete(uiMan.parents)
	delete(uiMan.widgets)
}

BeginFrame :: proc(uiMan: ^UiManager, worldCamera: Maybe(rl.Camera2D)) {
	uiMan.frame += 1
	resetCtr := false
	if uiMan.frame == MAX_FRAME_CNT {
		uiMan.frame = 0
		resetCtr = true
	}

	clear(&uiMan.nodes)
	clear(&uiMan.parents)

	cam, ok := worldCamera.?
	if ok {
		uiMan.worldCamera = cam
	}

	zoom := core.GetUiZoom()
	uiMan.camera.zoom = zoom
	uiMan.size = {
		math.floor(f32(rl.GetScreenWidth()) / zoom),
		math.floor(f32(rl.GetScreenHeight()) / zoom),
	}

	rawMouse := rl.GetMousePosition()
	uiMan.mouse[.SCREEN] = rawMouse / zoom
	uiMan.mouse[.WORLD] = rl.GetScreenToWorld2D(rawMouse, cam)

	uiMan.hovered = 0
	topSpace, topLayer, topOrder := Space(-1), Layer(-1), -1
	for id, state in uiMan.widgets {
		if state.lastSeen != uiMan.frame - 1 ||
		   resetCtr && (state.lastSeen != MAX_FRAME_CNT) ||
		   !state.capture {
			continue
		}
		if uiMan.menuOpen && state.layer != .MENU {
			continue
		}
		if !rl.CheckCollisionPointRec(uiMan.mouse[state.space], state.rect) {
			continue
		}

		if state.space > topSpace ||
		   (state.space == topSpace &&
				   (state.layer > topLayer ||
						   (state.layer == topLayer && (state.order > topOrder)))) {
			uiMan.hovered = id
			topSpace = state.space
			topLayer = state.layer
			topOrder = state.order
		}
	}

	uiMan.clicked = 0
	if rl.IsMouseButtonPressed(.LEFT) {
		uiMan.active = uiMan.hovered
	}

	if rl.IsMouseButtonReleased(.LEFT) {
		if uiMan.active != 0 && uiMan.active == uiMan.hovered {
			uiMan.clicked = uiMan.active
			uiMan.active = 0
		}
	}
}

EndFrame :: proc(uiMan: ^UiManager, texMan: ^texture.TextureManager) {
	// Sizes
	#reverse for &node in uiMan.nodes {
		padding := node.opts.padding
		extraSize := rl.Vector2{padding.left + padding.right, padding.top + padding.bottom}
		fit := (node.content != nil ? contentSize(&node, texMan) : node.childrenSize) + extraSize
		node.size = {sizeAxis(node.opts.size[0], fit.x), sizeAxis(node.opts.size[1], fit.y)}

		if node.parent >= 0 {
			addChild(&uiMan.nodes[node.parent], node.opts.size, node.size)
		}
	}

	uiMan.menuOpen = false
	for &node, idx in uiMan.nodes {
		if node.parent < 0 {
			node.position = placeRoot(uiMan, &node)
			if node.layer == .MENU {
				uiMan.menuOpen = true
			}
		} else {
			parent := &uiMan.nodes[node.parent]
			grow(parent, &node)
			node.position = placeChild(parent, &node)
		}

		padding := node.opts.padding
		node.cursor = {node.position.x + padding.left, node.position.y + padding.top}

		state := &uiMan.widgets[node.id]
		state.rect = core.MakeRect(node.position, node.size)
		state.space = node.space
		state.layer = node.layer
		state.order = idx
		state.capture = node.opts.capture
	}

	stale := make([dynamic]Id, context.temp_allocator)
	for id, state in uiMan.widgets {
		if state.lastSeen != uiMan.frame {
			append(&stale, id)
		}
	}
	for id in stale {
		delete_key(&uiMan.widgets, id)
	}
}

FlushScreen :: proc(uiMan: ^UiManager, texMan: ^texture.TextureManager) {
	for layer in Layer {
		if layer == .MENU && uiMan.menuOpen {
			render.DrawRect(GetScreen(uiMan, 0), SCRIM, {}, 0)
		}
		for &node in uiMan.nodes {
			if node.layer == layer && node.space == .SCREEN {
				drawNode(&node, texMan)
			}
		}
	}
}

FlushWorld :: proc(uiMan: ^UiManager, texMan: ^texture.TextureManager) {
	for &node in uiMan.nodes {
		if node.space == .WORLD {
			drawNode(&node, texMan)
		}
	}
}

WantsMouse :: proc(uiMan: ^UiManager) -> bool {
	if uiMan.menuOpen {
		return true
	}
	return false
}

WantsKeyboard :: proc(uiMan: ^UiManager) -> bool {
	if uiMan.menuOpen {
		return true
	}
	return false
}

AllowsClose :: proc(uiMan: ^UiManager) -> bool {
	if uiMan.textFieldActive {
		return false
	}
	return true
}
