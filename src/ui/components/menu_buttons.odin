package components

import "core:fmt"
import "src:core"
import "src:input"
import "src:render"
import "src:texture"
import "src:ui/layout"
import rl "vendor:raylib"

MenuButtonsState :: struct {}

@(private)
mbPlacement :: core.WidgetPlacement {
	target = core.CL,
	pivot  = core.CL,
	offset = {16, 0},
}

RenderMenuButtons :: proc(
	screen: rl.Rectangle,
	texMan: ^texture.TextureManager,
	frameInput: ^input.State,
) {
	size := rl.Vector2{200, 100}
	position := core.PlaceWidget(mbPlacement, size, screen)

	rl.DrawRectanglePro(core.MakeRect(position, size), {0, 0}, 0, rl.BLUE)

	rl.DrawCircleV(frameInput.mousePos / core.GetUiZoom(), 4, rl.RED)

	// Exit
	if (RenderTextButton("Exit", MenuButtonStyle, position + {0, 80}, frameInput, texMan)) {
		fmt.println("Clicked Exit")
	}


	// Start
	if (RenderTextButton("Start", MenuButtonStyle, position, frameInput, texMan)) {
		fmt.println("Clicked Start")
	}

	// Settings
	if (RenderTextButton("Settings", MenuButtonStyle, position + {0, 40}, frameInput, texMan)) {
		fmt.println("Clicked Settings")
	}
}
