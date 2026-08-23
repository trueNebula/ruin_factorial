package render

import "src:core"
import rl "vendor:raylib"

DrawSprite :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	sortY: bool,
) {
	append(&renMan.object, DrawCommand{texture = texture, src = src, dest = dest, sortY = sortY})
}

DrawTile :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
) {
	append(&renMan.tile, DrawCommand{texture = texture, src = src, dest = dest, sortY = false})
}

DrawRect :: proc(renMan: ^RenderManager, rect: rl.Rectangle, color: rl.Color) {
	append(&renMan.debug, ShapeDrawCommand{rect = rect, color = color})
}
