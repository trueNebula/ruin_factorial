package render

import "src:core"
import rl "vendor:raylib"

DrawSprite :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	sortY: bool,
	tint: rl.Color = rl.WHITE,
) {
	append(
		&renMan.object,
		DrawCommand{texture = texture, src = src, dest = dest, sortY = sortY, tint = tint},
	)
}

DrawShadow :: proc(
	renMan: ^RenderManager,
	shadow: core.Shadow,
	dest: rl.Vector2,
	tint: rl.Color = rl.WHITE,
) {
	src: rl.Rectangle

	switch shadow {
	case .SMALL:
		src = {
			x      = 240,
			y      = 0,
			width  = 16,
			height = 16,
		}
	case .LARGE:
		src = {
			x      = 224,
			y      = 0,
			width  = 16,
			height = 16,
		}
	}

	dest := dest
	dest.y += core.TileSize / 4

	append(
		&renMan.object,
		DrawCommand{texture = .ITEM, src = src, dest = dest, sortY = false, tint = tint},
	)
}

DrawTile :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	tint: rl.Color = rl.WHITE,
) {
	append(
		&renMan.tile,
		DrawCommand{texture = texture, src = src, dest = dest, sortY = false, tint = tint},
	)
}

DrawRect :: proc(renMan: ^RenderManager, rect: rl.Rectangle, color: rl.Color) {
	append(&renMan.debug, ShapeDrawCommand{rect = rect, color = color})
}
