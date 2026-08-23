package player

import "core:math/linalg"
import "src:core"
import "src:ecs"
import "src:input"
import "src:log"
import rl "vendor:raylib"

BASE_MOVEMENT_SPEED :: 1000

SetupPlayer :: proc(world: ^ecs.World) {
	transform := core.Transform {
		x        = 0,
		y        = 0,
		rotation = 0,
		sizeX    = 1,
		sizeY    = 1,
	}

	sprite := core.Sprite {
		texture = .PLAYER,
		rect = {x = 0, y = 0, width = 16, height = 16},
		anchor = .CENTER,
	}

	player := core.PlayerRef {
		id = 1,
	}

	velocity := core.Velocity{0, 0}

	camera := core.Camera {
		camera = rl.Camera2D {
			target = rl.Vector2{transform.x, transform.y},
			offset = core.GetScreenCenter(),
			zoom = 1.0 / 2,
			rotation = 0,
		},
	}

	ecs.Add(world, transform, velocity, sprite, camera, player)

	log.Debug("Added player with transform %+v and sprite %+v", transform, sprite)
}

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

PlayerMovementSystem :: proc(world: ^ecs.World) {
	ecs.Query4(
		world,
		nil,
		proc(
			transform: ^core.Transform,
			velocity: ^core.Velocity,
			player: ^core.PlayerRef,
			camera: ^core.Camera,
			userData: rawptr,
		) {
			dt := rl.GetFrameTime()

			transform.x += velocity.x * dt
			transform.y += velocity.y * dt
			camera.camera.target.x = transform.x
			camera.camera.target.y = transform.y
			velocity.x = 0
			velocity.y = 0
		},
	)
}
