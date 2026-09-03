package player

import "core:math"
import "core:math/linalg"
import "src:core"
import "src:ecs"
import "src:input"
import "src:log"
import rl "vendor:raylib"

MAIN_PLAYER_REF :: core.PlayerRef {
	id = 1,
}
BASE_MOVEMENT_SPEED :: 1000
INVENTORY_SLOTS :: 41 // 40 + mouse

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

	player := MAIN_PLAYER_REF
	velocity := core.Velocity{0, 0}

	camera := core.Camera {
		camera = rl.Camera2D {
			target = rl.Vector2{transform.x, transform.y},
			offset = core.GetScreenCenter(),
			zoom = 1.0 / 1,
			rotation = 0,
		},
	}

	inventory := core.Inventory {
		slots = make([]core.InventorySlot, INVENTORY_SLOTS),
		size  = INVENTORY_SLOTS,
	}

	inventory.slots[0] = {
		item  = .WOOD,
		count = 21,
	}

	log.Debug("Added inventory component: %+v", inventory)

	ecs.Add(world, transform, velocity, sprite, camera, player, inventory)

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

CameraTransformSystem :: proc(world: ^ecs.World) {
	ecs.Query2(world, nil, proc(player: ^core.PlayerRef, camera: ^core.Camera, userdata: rawptr) {
		if rl.IsWindowResized() {
			camera.camera.target.x = f32(rl.GetScreenWidth() / 2)
			camera.camera.target.y = f32(rl.GetScreenHeight() / 2)
		}

		camera.camera.zoom = core.DEBUG_DEFAULT_ZOOM * math.pow(2, core.DEBUG.zoom)
	})
}

GetPlayer :: proc(
	world: ^ecs.World,
	ref := MAIN_PLAYER_REF,
	tids: ..typeid,
) -> (
	components: ecs.ComponentSet,
	err: bool,
) {
	entityId := getPlayerId(world, ref)
	if entityId == 0 {
		return {}, true
	}

	return ecs.Get(world, entityId, ..tids), false
}

@(private)
getPlayerId :: proc(world: ^ecs.World, ref := MAIN_PLAYER_REF) -> u32 {
	view := ecs.View1(world, core.PlayerRef)
	for entity in view {
		if entity.id == ref.id {
			return entity.id
		}
	}

	return 0
}
