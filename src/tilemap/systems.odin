package tilemap

import "core:math/linalg"
import "src:collision"
import "src:core"
import "src:ecs"
import "src:event"
import "src:input"
import "src:item"
import "src:log"
import "src:neb_utils"
import "src:repository"
import "src:tilemap"
import rl "vendor:raylib"

@(private)
BREAK_DISTANCE :: core.TileSize * 5
@(private)
INTERACT_DISTANCE :: core.TileSize * 3

TilemapClickSystem :: proc(
	tileMan: ^TileManager,
	world: ^ecs.World,
	frameInput: ^input.State,
	camera: rl.Camera2D,
	repo: ^repository.Repository,
	queue: ^event.Queue,
) {
	if input.MaybeConsumeMouse(frameInput, .LEFT) {
		pos := rl.GetScreenToWorld2D(frameInput.mousePos, camera)
		if linalg.distance(pos, camera.target) > BREAK_DISTANCE do return

		_, block := GetTileAtScreenPos(tileMan, pos)
		if core.IsNone(block.id) do return

		def := repository.Get(&repo.blocks, block.id)
		blockPos := Screen2World(pos) * core.TileSize
		if block.offset != {} {
			_, ogBlock := GetTileOffsetFromWorldPos(
				tileMan,
				blockPos,
				-block.offset.x,
				-block.offset.y,
			)
			blockPos -= cast([2]f32)block.offset * core.TileSize
			block = ogBlock
		}

		health, err := ecs.GetComponentForEntity(world, block.entity, core.Health)
		transform, _ := ecs.GetComponentForEntity(world, block.entity, core.Transform)
		if err do return

		health.current -= 1
		if health.current <= 0 {
			ecs.Delete(world, block.entity)
			worldPos := blockPos + core.TileSize / 2
			breakTile(world, tileMan.repo, def, block.entity, GetMultiTileCenter(blockPos, def))
			block^ = {}

			for offset in def.tiles {
				_, offsetBlock := GetTileOffsetFromWorldPos(tileMan, worldPos, offset.x, offset.y)
				offsetBlock^ = {}
			}
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
	if input.MaybeConsumeMouse(frameInput, .RIGHT) {
		pos := rl.GetScreenToWorld2D(frameInput.mousePos, camera)
		if linalg.distance(pos, camera.target) > INTERACT_DISTANCE do return

		_, block := GetTileAtScreenPos(tileMan, pos)
		if core.IsNone(block.id) do return

		def := repository.Get(&repo.blocks, block.id)
		if len(def.collider.boxes) == 0 do return

		blockPos := Screen2World(pos) * core.TileSize
		transform, tErr := ecs.GetComponentForEntity(world, block.entity, core.Transform)
		if tErr do return

		for &box in def.collider.boxes {
			if .INTERACT in box.layer {
				if collision.CheckPointInCollider(&box, transform, pos) {
					inventory, invErr := ecs.GetComponentForEntity(
						world,
						block.entity,
						core.Inventory,
					)
					if invErr {
						log.Warn(
							"Tried opening block at pos %v with id %v, got no inventory.",
							pos,
							block.entity,
						)
						return
					}

					config := core.BlockConfig{}
					if def.storage != 0 {
						config.ui = .STORAGE
						config.input = inventory
						config.entity = block.entity
					}
					event.PushEvent(queue, event.Interact{config = config})
				}
			}
		}

	}
}

@(private)
breakTile :: proc(
	world: ^ecs.World,
	repo: ^repository.Repository,
	def: ^repository.BlockDef,
	entityId: u32,
	pos: rl.Vector2,
) {
	dropTable, err := ecs.GetComponentForEntity(world, entityId, core.DropTable)
	if err {
		return
	}

	totalWeight := core.GetTotalWeightFromTable(dropTable)
	rng := neb_utils.RandomRangeI32(1, totalWeight)

	for drop in dropTable {
		qty := item.RollQuantity(drop.qty)
		if (qty < 0 || qty > 65535) {
			log.Warn("Rolled quantity for range %+v, got %+v out of bounds!", drop.qty, qty)
			qty = 1
		}
		if drop.weight == -1 || rng < drop.weight {
			itemId, repoErr := repository.Find(&repo.items, drop.item)
			if repoErr {
				return
			}

			id := item.DropItem(world, repo, itemId, u16(qty), pos)
			continue
		}
	}

	if core.BlockFlag.DROP_SELF in def.flags {
		selfId, selfRepoErr := repository.Find(&repo.items, def.key)
		if selfRepoErr {
			return
		}
		item.DropItem(world, repo, selfId, 1, pos)
	}
}
