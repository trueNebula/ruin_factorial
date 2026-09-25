package render

import "src:core"
import "src:ecs"
import "src:log"
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

RenderShadows :: proc(world: ^ecs.World, renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	view := ecs.View2(world, core.Transform, core.Shadow)
	for entity in view {
		transform := entity.c1
		shadow := entity.c2
		dest := rl.Vector2{transform.x - core.TileSize / 2, transform.y - core.TileSize / 2}

		DrawShadow(renMan, shadow^, dest)
	}
}

RenderColliders :: proc(world: ^ecs.World, renMan: ^RenderManager) {
	view := ecs.View2(world, core.Collider, core.Transform)
	for entity in view {
		collider := entity.c1
		transform := entity.c2
		switch collider.type {
		case .CIRCLE:
			center := rl.Vector2{transform.x + collider.offset.x, transform.y + collider.offset.y}
			DrawCircle(renMan, center, collider.size.x, rl.BLUE)

		case .RECTANGLE:
			rect := rl.Rectangle {
				x      = transform.x + collider.offset.x,
				y      = transform.y + collider.offset.y,
				width  = collider.size.x,
				height = collider.size.y,
			}
			DrawRect(renMan, rect, rl.BLUE)
		}
	}
}
