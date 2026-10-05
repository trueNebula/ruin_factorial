package hotbar

import "src:core"
import "src:item"
import "src:log"
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

@(private)
slotSize :: 32.0
slotPadding :: 0.0
itemY :: 0.0
itemZoom :: 2.0

Render :: proc(
	state: ^HotbarState,
	screen: rl.Rectangle,
	renMan: ^render.RenderManager,
	texMan: ^texture.TextureManager,
) {
	sprite, _ := texture.GetTexture(texMan, .UI_HOTBAR)
	size := core.ToVector(sprite.width, sprite.height)
	position := core.PlaceWidget(placement, size, screen)

	render.DrawUiSprite(renMan, .UI_HOTBAR, {x = 0, y = 0, width = 320, height = 32}, position)

	for slot, idx in state.slots {
		if slot.id == .NONE {
			continue
		}

		slotItemPos := rl.Vector2{f32(idx) * slotSize + slotPadding, itemY} + position
		itemSrc, err := item.GetRectForId(slot.id)

		if err {
			log.Warn("Tried rendering unloaded item with ID %v in hotbar!", slot.id)
			continue
		}

		render.DrawUiSprite(renMan, .ITEM, itemSrc, slotItemPos, itemZoom)
	}
}
