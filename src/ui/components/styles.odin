package components

import "src:core"
import t "src:texture"
import rl "vendor:raylib"

InventorySlotCountStyle :: core.TextStyle {
	font = .MAIN,
	size = 11,
	spacing = t.MAIN_FONT_SPACING,
	line_height = 10,
	color = rl.WHITE,
	shadow = core.TextShadow{color = rl.BLACK, offset = {1, 1}},
}

MenuButtonStyle :: core.TextStyle {
	font        = .MAIN,
	size        = 22,
	spacing     = t.MAIN_FONT_SPACING,
	line_height = 22,
	color       = rl.WHITE,
}

ContainerNS :: core.NineSlice {
	texture = .UI,
	rect    = {16, 0, 16, 16},
	scale   = 2,
	mode    = .STRETCH,
	border  = core.Edges{3, 3, 3, 3},
}

@(private)
pad :: proc {
	padAll,
	padXY,
	padIndividual,
}

@(private)
padAll :: proc(amt: f32) -> core.Edges {
	return {amt, amt, amt, amt}
}

@(private)
padX :: proc(amt: f32) -> core.Edges {
	return {amt, 0, amt, 0}
}

@(private)
padY :: proc(amt: f32) -> core.Edges {
	return {0, amt, 0, amt}
}

@(private)
padXY :: proc(x, y: f32) -> core.Edges {
	return {x, y, x, y}
}

@(private)
padIndividual :: proc(l, t, r, b: f32) -> core.Edges {
	return {l, t, r, b}
}
