package ui

import "core:math"
import "src:core"
import rl "vendor:raylib"

@(require_results, deferred_in_out = endRoot)
Root :: proc(uiMan: ^UiManager, label: string, layer: Layer, opts: BoxOpts) -> bool {
	id := makeId(uiMan, label)
	touch(uiMan, id)
	idx := pushNode(uiMan, id, opts)
	node := &uiMan.nodes[idx]
	node.layer = layer
	node.space = .SCREEN // TODO: support .WORLD

	return true
}

@(private)
endRoot :: proc(uiMan: ^UiManager, label: string, layer: Layer, opts: BoxOpts, open: bool) {
	if open {
		popNode(uiMan)
	}
}

@(require_results, deferred_in_out = endBox)
Box :: proc(uiMan: ^UiManager, label: string, opts: BoxOpts) -> bool {
	id := makeId(uiMan, label)
	touch(uiMan, id)
	pushNode(uiMan, id, opts)

	return true
}

@(private)
endBox :: proc(uiMan: ^UiManager, label: string, opts: BoxOpts, open: bool) {
	if open {
		popNode(uiMan)
	}
}

Button :: proc(
	uiMan: ^UiManager,
	label: string,
	style: core.TextStyle = {},
	placement: core.WidgetPlacement = {},
) -> Response {
	id := makeId(uiMan, label)
	touch(uiMan, id)
	idx := addNode(uiMan, id, BoxOpts{placement = placement, capture = true})
	text := TextContent {
		str   = label,
		style = style,
	}
	response := respond(uiMan, id)

	if response.hovered {
		text.style.color.a /= 2
	}

	uiMan.nodes[idx].content = text

	return response
}

Label :: proc(
	uiMan: ^UiManager,
	label: string,
	text: string,
	style: core.TextStyle = {},
	placement: core.WidgetPlacement,
) {
	id := makeId(uiMan, label)
	touch(uiMan, id)
	idx := addNode(uiMan, id, BoxOpts{placement = placement})
	uiMan.nodes[idx].content = TextContent {
		str   = text,
		style = style,
	}
}
