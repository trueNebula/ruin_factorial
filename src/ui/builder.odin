package ui

import "core:math"
import "core:prof/spall"
import "src:core"
import rl "vendor:raylib"

@(require_results, deferred_in_out = endRoot)
Root :: proc(
	uiMan: ^UiManager,
	label: string,
	layer: Layer,
	attach: Attach,
	opts: BoxOpts = {},
) -> bool {
	core.Scope("ui.builder.Root")

	id := MakeId(uiMan, label)
	touch(uiMan, id)
	idx := pushNode(uiMan, id, opts)
	node := &uiMan.nodes[idx]
	node.layer = layer
	node.space = .SCREEN // TODO: support .WORLD
	node.attach = attach

	return true
}

@(private)
endRoot :: proc(
	uiMan: ^UiManager,
	label: string,
	layer: Layer,
	attach: Attach,
	opts: BoxOpts,
	open: bool,
) {
	if open {
		popNode(uiMan)
	}
}

@(require_results, deferred_in_out = endBox)
Box :: proc(uiMan: ^UiManager, label: string, opts: BoxOpts) -> bool {
	core.Scope("ui.builder.Box")

	id := MakeId(uiMan, label)
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

@(require_results, deferred_in_out = endClickableBox)
ClickableBox :: proc(
	uiMan: ^UiManager,
	label: string,
	opts: BoxOpts,
) -> (
	response: Response,
	open: bool,
) {
	core.Scope("ui.builder.ClickableBox")

	id := MakeId(uiMan, label)
	touch(uiMan, id)
	opts := opts
	opts.capture = true
	pushNode(uiMan, id, opts)

	return respond(uiMan, id), true
}

@(private)
endClickableBox :: proc(
	uiMan: ^UiManager,
	label: string,
	opts: BoxOpts,
	response: Response,
	open: bool,
) {
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
	core.Scope("ui.builder.Button")

	id := MakeId(uiMan, label)
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
	core.Scope("ui.builder.Label")

	id := MakeId(uiMan, label)
	touch(uiMan, id)
	idx := addNode(uiMan, id, BoxOpts{placement = placement})
	uiMan.nodes[idx].content = TextContent {
		str   = text,
		style = style,
	}
}

Scrim :: proc(uiMan: ^UiManager, label: string, color: rl.Color = SCRIM) {
	core.Scope("ui.builder.Scrim")

	id := MakeId(uiMan, label)
	touch(uiMan, id)
	addNode(
		uiMan,
		id,
		BoxOpts{background = FlatBackground{fill = color}, size = {{.GROW, 1}, {.GROW, 1}}},
	)
}
