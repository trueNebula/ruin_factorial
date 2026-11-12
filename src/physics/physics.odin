package physics

import "src:core"
import "src:ecs"
import "src:tilemap"
import rl "vendor:raylib"

MovementSystem :: proc(world: ^ecs.World, tileMan: ^tilemap.TileManager) {
	// Figure out the chunk the entity is in
	// Make a radius of 4 blocks around the player, figure out the chunks that those blocks are a part of
	// Fetch those blocks from the tilemap, block layer
	// For each block, fetch entity from world, get collision component, get boxes on layer WORLD
	// Test collision against all those and move the player
	view := ecs.View2(world, core.Transform, core.Velocity)

	simpleApplyVelocity :: proc(transform: ^core.Transform, velocity: ^core.Velocity, dt: f32) {
		transform.x += velocity.x * dt
		transform.y += velocity.y * dt
		velocity.x = 0
		velocity.y = 0
	}

	for entity in view {
		dt := core.FrameTime()
		transform := entity.c1
		velocity := entity.c2
		collider, noCollider := ecs.GetComponentForEntity(world, entity.id, core.Collider)
		pos := rl.Vector2{transform.x, transform.y}
		obstacles := make([dynamic]BoxView, context.temp_allocator)

		if !noCollider {
			for y in -1 ..= 1 {
				for x in -1 ..= 1 {
					_, block := tilemap.GetTileOffsetFromWorldPos(tileMan, pos, x, y)
					if block == nil || block.entity == 0 do continue

					blockTransform, tErr := ecs.GetComponentForEntity(
						world,
						block.entity,
						core.Transform,
					)
					blockCollider, cErr := ecs.GetComponentForEntity(
						world,
						block.entity,
						core.Collider,
					)
					if tErr || cErr do continue

					for &blockBox in blockCollider.boxes {
						if .WORLD not_in blockBox.layer do continue
						append(
							&obstacles,
							BoxView {
								id = block.entity,
								collider = &blockBox,
								transform = blockTransform,
							},
						)
					}
				}
			}
		}

		for axis in 0 ..< 2 {
			amount := velocity[axis] * dt

			if noCollider {
				pos[axis] += amount
			} else {
				moveAlongAxis(collider.boxes[:], &pos, axis, amount, obstacles[:])
			}
		}

		transform.x = pos.x
		transform.y = pos.y
		velocity^ = {0, 0}
	}
}

@(private)
moveAlongAxis :: proc(
	boxes: []core.CollisionBox,
	pos: ^rl.Vector2,
	axis: int,
	amount: f32,
	obstacles: []BoxView,
) {
	start := pos[axis]
	target := start + amount

	pos[axis] = target
	if !touchesBox(boxes, pos^, obstacles) do return

	pos[axis] = start
	if touchesBox(boxes, pos^, obstacles) {
		pos[axis] = target
		return
	}

	clearCoord := start
	blockedCoord := target
	for _ in 0 ..< 5 {
		middle := (clearCoord + blockedCoord) / 2
		pos[axis] = middle

		if touchesBox(boxes, pos^, obstacles) {
			blockedCoord = middle
		} else {
			clearCoord = middle
		}
	}

	pos[axis] = clearCoord
}

@(private)
touchesBox :: proc(boxes: []core.CollisionBox, pos: rl.Vector2, obstacles: []BoxView) -> bool {
	transform := core.Transform {
		x = pos.x,
		y = pos.y,
	}

	for &box in boxes {
		if .WORLD not_in box.mask do continue

		for obstacle in obstacles {
			if CheckCollision(&box, &transform, obstacle.collider, obstacle.transform) {
				return true
			}
		}
	}

	return false
}
