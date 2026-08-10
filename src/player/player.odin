package player

import "core:math/linalg"
import "src:core"
import "src:ecs"
import "src:input"
import "src:log"
import rl "vendor:raylib"

BASE_MOVEMENT_SPEED :: 200

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
			zoom = 4.0,
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

PlayerCameraSystem :: proc(world: ^ecs.World) {
	ecs.Query3(
		world,
		nil,
		proc(
			_: ^core.PlayerRef,
			transform: ^core.Transform,
			camera: ^core.Camera,
			userData: rawptr,
		) {
			camera.camera.target.x = transform.x
			camera.camera.target.y = transform.y
		},
	)
}
