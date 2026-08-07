package scene

import "src:core"
import "src:ecs"
import "src:log"
import "src:texture"
import rl "vendor:raylib"

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

	camera := core.Camera {
		camera = rl.Camera2D {
			target = rl.Vector2{transform.x, transform.y},
			offset = core.GetScreenCenter(),
			zoom = 4.0,
			rotation = 0,
		},
	}

	ecs.Add(world, transform, sprite, camera, player)

	log.Debug("Added player with transform %+v and sprite %+v", transform, sprite)
}
