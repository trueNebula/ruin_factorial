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
	append(&renMan.tile, DrawCommand{texture = texture, src = src, dest = dest, sortY = sortY})
}
