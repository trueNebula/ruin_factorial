package physics

import "src:core"
import "src:ecs"
import "src:event"
import rl "vendor:raylib"

CheckCollision :: proc(
	a: ^core.Collider,
	aTrans: ^core.Transform,
	b: ^core.Collider,
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
	view := ecs.View2(world, core.Collider, core.Transform)
	for i in 0 ..< len(view) {
		a := view[i]
		for j in i + 1 ..< len(view) {
			b := view[j]

			aWants := wantsCollision(a.c1.mask, b.c1.layer)
			bWants := wantsCollision(b.c1.mask, a.c1.layer)

			if !aWants && !bWants do continue

			if CheckCollision(a.c1, a.c2, b.c1, b.c2) {
				aIsPlayer, bIsPlayer := false, false

				if _, aErr := ecs.GetComponentForEntity(world, a.id, core.PlayerRef); !aErr {
					aIsPlayer = true
				}
				if _, bErr := ecs.GetComponentForEntity(world, b.id, core.PlayerRef); !bErr {
					bIsPlayer = true
				}

				if aWants {
					event.PushEvent(
						queue,
						event.Collision{a.id, b.id, aIsPlayer, bIsPlayer, a.c1.mask & b.c1.layer},
					)
				}
				if bWants {
					event.PushEvent(
						queue,
						event.Collision{b.id, a.id, aIsPlayer, bIsPlayer, b.c1.mask & a.c1.layer},
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
	case .ITEM in collision.onLayers && collision.selfIsPlayer:
		event.PushEvent(queue, event.Pickup{collector = collision.self, item = collision.other})
	case:
	}
}
