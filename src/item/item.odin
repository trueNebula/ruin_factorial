package item

import "core:math"
import "src:core"
import "src:ecs"
import "src:log"
import "src:neb_utils"
import rl "vendor:raylib"

DropItem :: proc(world: ^ecs.World, itemId: core.ItemId, qty: u16, pos: rl.Vector2) -> u32 {
	rect, err := GetRectForId(itemId)

	if err {
		return 0
	}

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

	float := core.Float {
		amplitude = 2,
		frequency = 2,
	}

	shadow := core.Shadow.SMALL

	return ecs.Add(world, item, sprite, transform, float, shadow)
}

GetRectForId :: proc(itemId: core.ItemId) -> (rect: rl.Rectangle, err: bool) {
	#partial switch itemId {
	case .WOOD:
		return {x = 0, y = 0, width = 16, height = 16}, false
	}

	log.Warn("Tried getting rect for item id %+v, doesn't exist!", itemId)
	return {}, true
}

RollQuantity :: proc(range: core.RangeInt) -> int {
	return int(neb_utils.RandomRangeGaussian(f32(range.min), f32(range.max)))
}

FloatItem :: proc(world: ^ecs.World) {
	view := ecs.View2(world, core.Sprite, core.Float)

	for entity in view {
		sprite := entity.c1
		float := entity.c2

		float.timer += rl.GetFrameTime()

		if float.timer >= 2 * math.PI {
			float.timer -= 2 * math.PI
		}

		offset := math.sin_f32(float.timer * float.frequency) * float.amplitude
		sprite.offsetY = -offset
	}
}
