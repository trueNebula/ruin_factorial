package render

import "src:core"
import "src:ecs"
import "src:log"
import "src:texture"
import rl "vendor:raylib"

RenderSprites :: proc(world: ^ecs.World, renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	RenderSpritesContext :: struct {
		renderManager:  ^RenderManager,
		textureManager: ^texture.TextureManager,
	}
	ecs.Query2(
		world,
		rawptr(&RenderSpritesContext{renderManager = renMan, textureManager = texMan}),
		proc(transform: ^core.Transform, sprite: ^core.Sprite, userData: rawptr) {
			ctx := cast(^RenderSpritesContext)userData
			renMan := ctx.renderManager
			texMan := ctx.textureManager
			tex, err := texture.GetTexture(texMan, sprite.texture)
			dest := core.GetDestRect(transform^, sprite^)
			spriteSize := core.Rect2Size(dest)

			switch sprite.anchor {
			case .CENTER:
				dest = core.MoveRect(dest, -spriteSize / 2)
			case .BOTTOM_LEFT:
				dest = core.MoveRect(dest, -spriteSize)
			case .TOP_LEFT:
			}

			if (err) {
				log.Err(
					"Unable to get texture with ID %s. Unloaded?",
					sprite.texture,
					panic = false,
				)
			}

			DrawSprite(renMan, sprite.texture, sprite.rect, core.GetPos(dest), true)
		},
	)
}
