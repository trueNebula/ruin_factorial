package components

import "core:fmt"
import "src:core"
import "src:input"
import "src:render"
import "src:texture"
import "src:ui/layout"
import rl "vendor:raylib"

RenderTextButton :: proc(
	text: string,
	style: core.TextStyle,
	position: rl.Vector2,
	frameInput: ^input.State,
	texMan: ^texture.TextureManager,
) -> bool {
	fontData, err := texture.GetFont(texMan, style.font)

	if err {
		return false
	}

	textStr := fmt.ctprint(text)
	size := rl.MeasureTextEx(fontData.resource, textStr, style.size, style.spacing)
	btnRect := layout.Padding(core.MakeRect(position, size), style.padding[0]) // TODO: remove temp [0]
	hovered: bool

	uiZoom := core.GetUiZoom()

	if (rl.CheckCollisionPointRec(frameInput.mousePos / uiZoom, btnRect)) {
		hovered = true
	}

	fontSize := hovered ? style.size + 4 : style.size
	tint := hovered ? rl.Color{210, 240, 255, 255} : rl.WHITE

	rl.DrawRectanglePro(btnRect, {0, 0}, 0, rl.GREEN)
	render.DrawText(textStr, fontData, position, fontSize, tint)

	return hovered && input.MaybeConsumeMouse(frameInput, .LEFT)
}
