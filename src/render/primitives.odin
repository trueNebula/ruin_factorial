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
