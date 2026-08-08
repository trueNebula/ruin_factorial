package player

import "core:math/linalg"
import "src:core"
import "src:ecs"
import "src:input"
import rl "vendor:raylib"

BASE_MOVEMENT_SPEED :: 200

PlayerInputSystem :: proc(world: ^ecs.World, frameInput: ^input.State) {
	ecs.Query2(world, frameInput, proc(player: ^core.PlayerRef, velocity: ^core.Velocity, userData: rawptr) {
		frameInput := cast(^input.State)userData
		if .UP in frameInput.actionHeld do velocity.y -= 1
		if .DOWN in frameInput.actionHeld do velocity.y += 1
		if .LEFT in frameInput.actionHeld do velocity.x -= 1
		if .RIGHT in frameInput.actionHeld do velocity.x += 1
		velocity^ = linalg.normalize0(velocity^) * BASE_MOVEMENT_SPEED
	})
}
