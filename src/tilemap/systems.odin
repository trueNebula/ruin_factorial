package tilemap

import "src:core"
import "src:ecs"
import "src:input"
import "src:log"
import rl "vendor:raylib"

TilemapClickSystem :: proc(
	tileMan: ^TileManager,
	world: ^ecs.World,
	frameInput: ^input.State,
	camera: rl.Camera2D,
) {
	if input.MaybeConsumeMouse(frameInput, .LEFT) {
		pos := rl.GetScreenToWorld2D(frameInput.mousePos, camera)
		_, block := GetTileAtScreenPos(tileMan, pos)
		if block.id == .NONE {
			return
		}

		health, err := ecs.GetComponentForEntity(world, block.entity, core.Health)

		if err {
			return
		}

		log.Debug("Clicked on pos %v, got block %+v with component &+v", pos, block, health)

		health.current -= 1
		if health.current <= 0 {
			ecs.Delete(world, block.entity)
			block.entity = 0
			block.id = .NONE
		}
	}
}
