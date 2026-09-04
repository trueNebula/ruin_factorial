package render

import "src:core"
import "src:ecs"
import "src:log"
import "src:neb_utils"
import "src:texture"
import rl "vendor:raylib"

RenderSprites :: proc(world: ^ecs.World, renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	view := ecs.View2(world, core.Transform, core.Sprite)
	for entity in view {
		transform := entity.c1
		sprite := entity.c2
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

		tintDest := rl.WHITE
		if tint, err := ecs.GetComponentForEntity(world, entity.id, core.Tint); !err {
			tintDest = tint^
		}

		if tween, err2 := ecs.GetComponentForEntity(world, entity.id, core.TintTween); !err2 {
			tintDest = core.DoTintTweenMath(tween^, tintDest)
		}

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", sprite.texture, panic = false)
		}

		DrawSprite(renMan, sprite.texture, sprite.rect, core.GetPos(dest), true, tintDest)
	}
}

ApplyTintTween :: proc(world: ^ecs.World) {
	view := ecs.View1(world, core.TintTween)

	for entity in view {
		tween := entity.c1
		dt := rl.GetFrameTime()
		tween.timer += dt

		if tween.timer >= tween.duration {
			ecs.DeleteComponent(world, entity.id, core.TintTween)
			return
		}
	}
}
