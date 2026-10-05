package hotbar

import "src:core"
import "src:render"
import "src:texture"
import rl "vendor:raylib"

Hotbar :: struct {}

HotbarState :: struct {
	slots:    []core.Item,
	size:     int,
	selected: int,
}

@(private)
placement :: core.WidgetPlacement {
	target = core.BC,
	pivot  = core.BC,
}

Render :: proc(
	state: HotbarState,
	screen: rl.Rectangle,
	renMan: ^render.RenderManager,
	texMan: ^texture.TextureManager,
) {
	sprite, _ := texture.GetTexture(texMan, .UI_HOTBAR)
	size := core.ToVector(sprite.width, sprite.height)
	position := core.PlaceWidget(placement, size, screen)

	render.DrawUiSprite(renMan, .UI_HOTBAR, {x = 0, y = 0, width = 320, height = 32}, position)
}
