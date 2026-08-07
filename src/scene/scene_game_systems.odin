package scene

import "src:core"
import "src:ecs"
import "src:log"
import "src:texture"

SetupPlayer :: proc(world: ^ecs.World) {
	transform := core.Transform {
		x        = 200,
		y        = 200,
		rotation = 0,
		sizeX    = 4,
		sizeY    = 4,
	}

	sprite := core.Sprite {
		texture = .PLAYER,
		rect = {x = 0, y = 0, width = 16, height = 16},
	}

	ecs.Add(world, transform, sprite)

	log.Debug("Added player with transform %+v and sprite %+v", transform, sprite)
}
