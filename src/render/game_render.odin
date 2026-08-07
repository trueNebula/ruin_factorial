package render

import "src:core"
import "src:ecs"
import "src:log"
import "src:texture"
import rl "vendor:raylib"

RenderSprites :: proc(world: ^ecs.World, texMan: ^texture.TextureManager) {
	ecs.Query2(
		world,
		texMan,
		proc(transform: ^core.Transform, sprite: ^core.Sprite, userData: rawptr) {
			texMan := cast(^texture.TextureManager)userData
			tex, err := texture.GetTexture(texMan, sprite.texture)
			dest := core.GetDestRect(transform^, sprite^)
			spriteSize := core.Rect2Size(dest)

			switch sprite.anchor {
			case .CENTER:
				dest = core.MoveRect(dest, -spriteSize / 2)
			case .BOTTOM_LEFT:
				dest = core.MoveRect(dest, -spriteSize)
			}

			if (err) {
				log.Err(
					"Unable to get texture with ID %s. Unloaded?",
					sprite.texture,
					panic = false,
				)
			}

			rl.DrawTexturePro(tex, sprite.rect, dest, {0, 0}, transform.rotation, rl.WHITE)
		},
	)
}
