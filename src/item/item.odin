package item

import "core:math"
import "src:core"
import "src:ecs"
import "src:log"
import "src:neb_utils"
import "src:repository"
import rl "vendor:raylib"

SCATTER_GRAVITY :: 512

DropItem :: proc(
	world: ^ecs.World,
	repo: ^repository.Repository,
	itemId: core.ItemId,
	qty: u16,
	pos: rl.Vector2,
) -> u32 {
	itemDef := repository.Get(&repo.items, itemId)
	rect := itemDef.rect
	sprite := core.Sprite {
		texture = core.Texture.ITEM,
		rect    = rect,
		anchor  = .CENTER,
	}

	item := core.Item {
		id    = itemId,
		count = qty,
	}

	transform := core.Transform {
		x        = pos.x,
		y        = pos.y,
		rotation = 0,
		sizeX    = 1,
		sizeY    = 1,
	}

	shadow := core.Shadow.SMALL

	scatter := core.ItemScatter {
		duration = 0.5,
		velocity = {
			neb_utils.RandomRangeGaussian(-core.TileSize * 4, core.TileSize * 4),
			-neb_utils.RandomRangeGaussian(core.TileSize * 8, core.TileSize * 9),
		},
		gravity  = SCATTER_GRAVITY,
	}

	return ecs.Add(world, item, sprite, transform, shadow, scatter)
}

RollQuantity :: proc(range: core.RangeInt) -> int {
	return int(neb_utils.RandomRangeGaussian(f32(range.min), f32(range.max)))
}

FloatItem :: proc(world: ^ecs.World) {
	view := ecs.View2(world, core.Sprite, core.Float)

	for entity in view {
		sprite := entity.c1
		float := entity.c2

		float.timer += core.FrameTime()

		if float.timer >= 2 * math.PI {
			float.timer -= 2 * math.PI
		}

		offset := math.sin_f32(float.timer * float.frequency) * float.amplitude
		sprite.offsetY = -offset
	}
}

ScatterItem :: proc(world: ^ecs.World) {
	view := ecs.View2(world, core.ItemScatter, core.Transform)

	for entity in view {
		scatter := entity.c1
		transform := entity.c2

		dt := core.FrameTime()
		scatter.timer += dt

		if scatter.timer >= scatter.duration {
			float := core.Float {
				amplitude = 2,
				frequency = 2,
				timer     = neb_utils.RandomRange(0, 2 * math.PI),
			}

			collider := core.Collider {
				type   = .CIRCLE,
				offset = {0, 0},
				size   = {6, 0},
				layer  = {.ITEM},
				mask   = {},
			}

			ecs.AddComponent(world, entity.id, float)
			ecs.AddComponent(world, entity.id, collider)
			ecs.DeleteComponent(world, entity.id, core.ItemScatter)
			return
		}

		transform.x += scatter.velocity.x * dt
		transform.y += scatter.velocity.y * dt
		scatter.velocity.y += scatter.gravity * dt
	}
}
