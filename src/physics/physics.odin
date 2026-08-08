package physics

import "src:core"
import "src:ecs"
import rl "vendor:raylib"

MovementSystem :: proc(world: ^ecs.World) {
	ecs.Query2(
		world,
		nil,
		proc(transform: ^core.Transform, velocity: ^core.Velocity, userData: rawptr) {
			dt := rl.GetFrameTime()

			transform.x += velocity.x * dt
			transform.y += velocity.y * dt
			velocity.x = 0
			velocity.y = 0
		},
	)
}
