package tilemap

import "src:core"
import "src:ecs"
import "src:input"
import "src:item"
import "src:log"
import "src:neb_utils"
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

		health.current -= 1
		if health.current <= 0 {
			ecs.Delete(world, block.entity)
			worldPos := Screen2World(pos)
			breakTile(world, block.entity, worldPos)
			block.entity = 0
			block.id = .NONE
			return
		}

		tintTween := core.TintTween {
			destination = rl.Color{0, 0, 0, 127},
			duration    = 0.3,
			curve       = .EASE_OUT,
			reverse     = true,
		}

		ecs.AddComponent(world, block.entity, tintTween)
	}
}

@(private)
breakTile :: proc(world: ^ecs.World, entityId: u32, pos: rl.Vector2) {
	dropTable, err := ecs.GetComponentForEntity(world, entityId, core.DropTable)
	if err {
		return
	}

	totalWeight := core.GetTotalWeightFromTable(dropTable)
	rng := neb_utils.RandomRangeI32(1, totalWeight)

	for drop in dropTable.drops {
		qty := item.RollQuantity(drop.qty)
		if (qty < 0 || qty > 65535) {
			log.Warn("Rolled quantity for range %+v, got %+v out of bounds!", drop.qty, qty)
			qty = 1
		}
		if drop.weight == -1 || rng < drop.weight {
			id := item.DropItem(world, drop.item, u16(qty), pos)
			log.Debug("tile id: %+v, item id: %+v", entityId, id)
			continue
		}
	}
}
