package physics

import "src:core"
import "src:ecs"
import "src:event"
import rl "vendor:raylib"

@(private)
BoxView :: struct {
	id:        u32,
	collider:  ^core.CollisionBox,
	transform: ^core.Transform,
}

@(private)
ColliderMap :: map[core.ColliderLayer][dynamic]BoxView

CheckCollision :: proc(
	a: ^core.CollisionBox,
	aTrans: ^core.Transform,
	b: ^core.CollisionBox,
	bTrans: ^core.Transform,
) -> bool {
	if a.type == .RECTANGLE {
		aCollider := rl.Rectangle {
			x      = aTrans.x + a.offset.x,
			y      = aTrans.y + a.offset.y,
			width  = a.size.x,
			height = a.size.y,
		}
		if b.type == .RECTANGLE {
			bCollider := rl.Rectangle {
				x      = bTrans.x + b.offset.x,
				y      = bTrans.y + b.offset.y,
				width  = b.size.x,
				height = b.size.y,
			}
			return rl.CheckCollisionRecs(aCollider, bCollider)
		} else {
			bCenter := rl.Vector2{bTrans.x + b.offset.x, bTrans.y + b.offset.y}
			return rl.CheckCollisionCircleRec(bCenter, b.size.x, aCollider)
		}
	} else {
		aCenter := rl.Vector2{aTrans.x + a.offset.x, aTrans.y + a.offset.y}
		if b.type == .RECTANGLE {
			bCollider := rl.Rectangle {
				x      = bTrans.x + b.offset.x,
				y      = bTrans.y + b.offset.y,
				width  = b.size.x,
				height = b.size.y,
			}
			return rl.CheckCollisionCircleRec(aCenter, a.size.x, bCollider)
		} else {
			bCenter := rl.Vector2{bTrans.x + b.offset.x, bTrans.y + b.offset.y}
			return rl.CheckCollisionCircles(aCenter, a.size.x, bCenter, b.size.x)
		}
	}
	return false
}

CheckCollisions :: proc(world: ^ecs.World, queue: ^event.Queue) {
	// TODO: implement hash grid to make this faster
	layerMap, maskMap := collectBoxes(world)

	for layer in core.ColliderLayer {
		if len(layerMap[layer]) == 0 || len(maskMap[layer]) == 0 {
			continue
		}

		for a in maskMap[layer] {
			for b in layerMap[layer] {
				if CheckCollision(a.collider, a.transform, b.collider, b.transform) {
					aIsPlayer, bIsPlayer := false, false

					if _, aErr := ecs.GetComponentForEntity(world, a.id, core.PlayerRef); !aErr {
						aIsPlayer = true
					}
					if _, bErr := ecs.GetComponentForEntity(world, b.id, core.PlayerRef); !bErr {
						bIsPlayer = true
					}

					event.PushEvent(
						queue,
						event.Collision{a.id, b.id, aIsPlayer, bIsPlayer, layer},
					)
				}
			}
		}
	}
}

@(private)
wantsCollision :: proc(a, b: core.CollisionLayers) -> bool {
	return a & b != {}
}

RouteCollision :: proc(collision: event.Collision, queue: ^event.Queue) {
	switch {
	case collision.onLayer == .ITEM && collision.selfIsPlayer:
		event.PushEvent(queue, event.Pickup{collector = collision.self, item = collision.other})
	case:
	}
}

// Goes through a view of entities with valid colliders and flattens all CollisionBoxes into BoxViews
// Returns them in two maps
@(private)
collectBoxes :: proc(world: ^ecs.World) -> (layer: ColliderMap, mask: ColliderMap) {
	layerMap := make(ColliderMap, context.temp_allocator)
	maskMap := make(ColliderMap, context.temp_allocator)
	view := ecs.View2(world, core.Collider, core.Transform)

	for entity in view {
		for &box in entity.c1.boxes {
			boxView := BoxView {
				id        = entity.id,
				collider  = &box,
				transform = entity.c2,
			}

			for layer in box.layer {
				if layer not_in layerMap {
					layerMap[layer] = make([dynamic]BoxView, context.temp_allocator)
				}
				append(&layerMap[layer], boxView)
			}

			for layer in box.mask {
				if layer not_in maskMap {
					maskMap[layer] = make([dynamic]BoxView, context.temp_allocator)
				}
				append(&maskMap[layer], boxView)
			}
		}
	}

	return layerMap, maskMap
}
