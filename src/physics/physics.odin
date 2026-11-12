package physics

import "core:math/linalg"
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

		pos += velocity^ * dt
		if !noCollider {
			for &box in collider.boxes {
				if .WORLD not_in box.mask do continue
				for obstacle in obstacles {
					push, hit := pushOut(
						&box,
						pos,
						obstacle.collider,
						{obstacle.transform.x, obstacle.transform.y},
					)
					if hit {
						pos += push
					}
				}
			}
		}

		transform.x = pos.x
		transform.y = pos.y
		velocity^ = {0, 0}
	}
}

@(private)
pushOut :: proc(
	mover: ^core.CollisionBox,
	moverPos: rl.Vector2,
	obstacle: ^core.CollisionBox,
	obstaclePos: rl.Vector2,
) -> (
	push: rl.Vector2,
	hit: bool,
) {
	switch {
	case mover.type == .CIRCLE && obstacle.type == .CIRCLE:
		moverCenter := moverPos + mover.offset
		obstacleCenter := obstaclePos + obstacle.offset
		centerToCenter := moverCenter - obstacleCenter
		centerToCenterDist := linalg.length(centerToCenter)
		touchDistance := mover.size.x + obstacle.size.x

		if centerToCenterDist >= touchDistance do return {}, false
		if centerToCenterDist == 0 do return {touchDistance, 0}, true

		return centerToCenter / centerToCenterDist * (touchDistance - centerToCenterDist), true

	case mover.type == .CIRCLE && obstacle.type == .RECTANGLE:
		moverCenter := moverPos + mover.offset
		radius := mover.size.x
		obstacleRect := core.MakeRect(obstaclePos + obstacle.offset, obstacle.size)

		closestPoint := rl.Vector2 {
			clamp(moverCenter.x, obstacleRect.x, obstacleRect.x + obstacleRect.width),
			clamp(moverCenter.y, obstacleRect.y, obstacleRect.y + obstacleRect.height),
		}
		pointToCenter := moverCenter - closestPoint
		distance := linalg.length(pointToCenter)

		if distance > radius do return {}, false
		if distance > 0 do return pointToCenter / distance * (radius - distance), true

		// The center of the circle is inside the rectangle
		toLeft := moverCenter.x - obstacleRect.x
		toTop := moverCenter.y - obstacleRect.y
		toRight := obstacleRect.x + obstacleRect.width - moverCenter.x
		toBot := obstacleRect.y + obstacleRect.height - moverCenter.y
		nearest := min(toLeft, toTop, toRight, toBot)

		if nearest == toLeft do return {-(toLeft + radius), 0}, true
		if nearest == toTop do return {0, -(toTop + radius)}, true
		if nearest == toRight do return {toRight + radius, 0}, true
		return {0, toBot + radius}, true

	case mover.type == .RECTANGLE && obstacle.type == .CIRCLE:
		push, hit := pushOut(obstacle, obstaclePos, mover, moverPos)
		return -push, hit

	case:
		moverRect := core.MakeRect(moverPos + mover.offset, mover.size)
		obstacleRect := core.MakeRect(obstaclePos + obstacle.offset, obstacle.size)
		overlapX :=
			min(moverRect.x + moverRect.width, obstacleRect.x + obstacleRect.width) -
			min(moverRect.x, obstacleRect.x)
		overlapY :=
			min(moverRect.y + moverRect.height, obstacleRect.y + obstacleRect.height) -
			min(moverRect.y, obstacleRect.y)

		if overlapX <= 0 || overlapY <= 0 do return {}, false

		moverCenter := rl.Vector2 {
			moverRect.x + moverRect.width / 2,
			moverRect.y + moverRect.height / 2,
		}
		obstacleCenter := rl.Vector2 {
			obstacleRect.x + obstacleRect.width / 2,
			obstacleRect.y + obstacleRect.height / 2,
		}

		if overlapX < overlapY {
			return {moverCenter.x < obstacleCenter.x ? -overlapX : overlapX, 0}, true
		}
		return {0, moverCenter.y < obstacleCenter.y ? -overlapY : overlapY}, true
	}
}
