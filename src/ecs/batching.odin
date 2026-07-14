package ecs

import "core:fmt"
import "core:reflect"
import "core:slice"

BatchManager :: struct {
	additions:   map[u32][dynamic]Component,
	deletions:   map[u32][dynamic]typeid,
	addQueue:    [dynamic]BatchAddCommand,
	deleteQueue: [dynamic]BatchDeleteCommand,
}

BatchAddCommand :: struct {
	src:        ^Archetype,
	dst:        ^Archetype,
	entities:   [dynamic]u32,
	components: map[typeid][dynamic]Component,
}

BatchDeleteCommand :: struct {
	src:        ^Archetype,
	dst:        ^Archetype,
	entities:   [dynamic]u32,
	components: [dynamic]typeid,
}

CommandType :: enum {
	ADD_COMPONENT,
	DELETE_COMPONENT,
}

Command :: struct {
	type:      CommandType,
	entityId:  u32,
	component: Component,
	tid:       typeid,
}

@(private)
addEntity :: proc(
	world: ^World,
	batch: ^BatchManager,
	entityId: u32,
	components: []Component,
) -> u32 {
	emptyMask := [4]u64{}
	arch := getOrCreateArchetype(world, &emptyMask)

	for component in components {
		addComponentToEntity(batch, entityId, component)
	}

	record := EntityRecord {
		archetype = arch,
		row       = len(arch.entities),
	}
	world.entities[entityId] = record
	append(&arch.entities, entityId)

	return entityId
}

@(private)
deleteEntity :: proc(world: ^World, batch: ^BatchManager, entityId: u32) {
	record := getRecord(world, entityId)
	tids := getComponentsFromMask(&record.archetype.mask)
	deletions: ^[dynamic]typeid = nil

	if compList, ok := &batch.deletions[entityId]; ok {
		deletions = compList
	} else {
		batch.deletions[entityId] = make([dynamic]typeid, context.temp_allocator)
		deletions = &batch.deletions[entityId]
	}

	for tid in tids {
		append(deletions, tid)
	}
}

@(private)
addComponentToEntity :: proc(batch: ^BatchManager, entityId: u32, component: Component) {
	if compList, ok := &batch.additions[entityId]; ok {
		append(compList, component)
	} else {
		batch.additions[entityId] = make([dynamic]Component, context.temp_allocator)
		append(&batch.additions[entityId], component)
	}
}

@(private)
deleteComponentFromEntity :: proc(batch: ^BatchManager, entityId: u32, tid: typeid) {
	if compList, ok := &batch.deletions[entityId]; ok {
		append(compList, tid)
	} else {
		batch.deletions[entityId] = make([dynamic]typeid, context.temp_allocator)
		append(&batch.deletions[entityId], tid)
	}
}

@(private)
processAdditionsIntoCommands :: proc(world: ^World, batch: ^BatchManager) {
	for entityId, &components in batch.additions {
		src := world.entities[entityId].archetype
		srcMask := src.mask

		diffMask := computeMask(world, components[:])
		dstMask := maskCombine(&srcMask, &diffMask)
		dst := getOrCreateArchetype(world, &dstMask)

		cmd: ^BatchAddCommand = nil

		for i in 0 ..< len(batch.addQueue) {
			if batch.addQueue[i].src == src && batch.addQueue[i].dst == dst {
				cmd = &batch.addQueue[i]
				break
			}
		}

		if cmd == nil {
			newCmd: BatchAddCommand = {
				src        = src,
				dst        = dst,
				entities   = make([dynamic]u32, context.temp_allocator),
				components = make(map[typeid][dynamic]Component, context.temp_allocator),
			}

			append(&batch.addQueue, newCmd)
			cmd = &batch.addQueue[len(batch.addQueue) - 1]
		}

		append(&cmd.entities, entityId)

		for &comp in components {
			tid := reflect.union_variant_typeid(comp)
			if _, ok := cmd.components[tid]; !ok {
				cmd.components[tid] = make([dynamic]Component, context.temp_allocator)
			}
			append(&cmd.components[tid], comp)
		}
	}
}

@(private)
processDeletionsIntoCommands :: proc(world: ^World, batch: ^BatchManager) {
	for entityId, &components in batch.deletions {
		src := world.entities[entityId].archetype
		srcMask := src.mask
		dstMask := src.mask

		for tid in components {
			bitIdx := world.meta[tid].bit
			word := bitIdx / 64
			bit := uint(bitIdx % 64)
			dstMask[word] &= ~(u64(1) << bit)
		}

		dst := getOrCreateArchetype(world, &dstMask)
		cmd: ^BatchDeleteCommand = nil

		for i in 0 ..< len(batch.deleteQueue) {
			if batch.deleteQueue[i].src == src && batch.deleteQueue[i].dst == dst {
				cmd = &batch.deleteQueue[i]
				break
			}
		}

		if cmd == nil {
			newCmd: BatchDeleteCommand = {
				src        = src,
				dst        = dst,
				entities   = make([dynamic]u32, context.temp_allocator),
				components = make([dynamic]typeid, context.temp_allocator),
			}

			for tid in components {
				append(&newCmd.components, tid)
			}

			append(&batch.deleteQueue, newCmd)
			cmd = &batch.deleteQueue[len(batch.deleteQueue) - 1]
		}

		append(&cmd.entities, entityId)
	}
}

@(private)
sortAdditionCommands :: proc(world: ^World, batch: ^BatchManager) {
	for &cmd in batch.addQueue {
		count := len(cmd.entities)
		if count <= 1 do continue

		for i := 0; i < count - 1; i += 1 {
			for j := 0; j < count - i - 1; j += 1 {
				row_a := world.entities[cmd.entities[j]].row
				row_b := world.entities[cmd.entities[j + 1]].row

				if row_a < row_b {
					cmd.entities[j], cmd.entities[j + 1] = cmd.entities[j + 1], cmd.entities[j]

					for tid, &payload_list in cmd.components {
						payload_list[j], payload_list[j + 1] = payload_list[j + 1], payload_list[j]
					}
				}
			}
		}
	}
}

@(private)
sortDeletionCommands :: proc(world: ^World, batch: ^BatchManager) {
	for &cmd in batch.deleteQueue {
		count := len(cmd.entities)
		if count <= 1 do continue

		slice.sort_by(cmd.entities[:], proc(i, j: u32) -> bool {
			return true
		})

		for i := 0; i < count - 1; i += 1 {
			for j := 0; j < count - i - 1; j += 1 {
				row_a := world.entities[cmd.entities[j]].row
				row_b := world.entities[cmd.entities[j + 1]].row
				if row_a < row_b {
					cmd.entities[j], cmd.entities[j + 1] = cmd.entities[j + 1], cmd.entities[j]
				}
			}
		}
	}
}

@(private)
executeAdditionCommands :: proc(world: ^World, batch: ^BatchManager) {
	for &cmd in batch.addQueue {
		batchMoveData(world, &cmd)
	}
}

@(private)
executeDeletionCommands :: proc(world: ^World, batch: ^BatchManager) {
	for &cmd in batch.deleteQueue {
		batchDeleteData(world, &cmd)
	}
}
