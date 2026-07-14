package ecs

// v1.0.0

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:reflect"

Entity :: struct {
	id: u32,
}

MAX_ENTITIES :: 1_000_000

World :: struct {
	archetypes: [dynamic]^Archetype,
	entities:   map[u32]EntityRecord,
	meta:       map[typeid]ComponentMeta,
	nextId:     u32,
	idQueue:    [dynamic]u32,
	arena:      mem.Arena,
	batch:      BatchManager,
	setup:      [dynamic]System,
	tick:       [dynamic]System,
	render:     [dynamic]System,
}

CreateWorld :: proc() -> World {
	world := World {
		archetypes = make([dynamic]^Archetype),
		entities = make(map[u32]EntityRecord),
		meta = make(map[typeid]ComponentMeta),
		nextId = 1,
		batch = BatchManager {
			additions = make(map[u32][dynamic]Component),
			deletions = make(map[u32][dynamic]typeid),
			addQueue = make([dynamic]BatchAddCommand),
			deleteQueue = make([dynamic]BatchDeleteCommand),
		},
	}

	info := type_info_of(Component)
	#partial switch variant in info.variant.(runtime.Type_Info_Named).base.variant {
	case runtime.Type_Info_Union:
		for variantInfo, idx in variant.variants {
			world.meta[variantInfo.id] = ComponentMeta {
				bit  = idx,
				size = variantInfo.size,
			}
		}
	}

	return world
}

USE_BATCHING :: true

Add :: proc(world: ^World, components: ..Component) -> u32 {
	entityId := getNextId(world)
	if USE_BATCHING {
		return addEntity(world, &world.batch, entityId, components)
	} else {
		return addInternal(world, entityId, components)
	}
}

Delete :: proc(world: ^World, entityId: u32) {
	append(&world.idQueue, entityId)
	if USE_BATCHING {
		deleteEntity(world, &world.batch, entityId)
	} else {
		deleteInternal(world, entityId)
	}
}

AddComponent :: proc(world: ^World, entityId: u32, component: Component) {
	if USE_BATCHING {
		addComponentToEntity(&world.batch, entityId, component)
	} else {
		addComponentInternal(world, entityId, component)
	}
}

GetComponent :: proc(world: ^World, entityId: u32, $T: typeid) -> (component: ^T, err: bool) {
	return getComponent(world, entityId, component)
}

DeleteComponent :: proc(world: ^World, entityId: u32, tid: typeid) {
	if USE_BATCHING {
		deleteComponentFromEntity(&world.batch, entityId, tid)
	} else {
		deleteComponentInternal(world, entityId, tid)
	}
}

FrameEnd :: proc(world: ^World) {
	batch := &world.batch
	processAdditionsIntoCommands(world, batch)
	processDeletionsIntoCommands(world, batch)

	// sortAdditionCommands(world, batch)
	// sortDeletionCommands(world, batch)

	executeAdditionCommands(world, batch)
	executeDeletionCommands(world, batch)

	clear(&batch.additions)
	clear(&batch.deletions)
	clear(&batch.addQueue)
	clear(&batch.deleteQueue)

	free_all(context.temp_allocator)
}

Initial :: proc(world: ^World) {
	batch := &world.batch
	processAdditionsIntoCommands(world, batch)
	executeAdditionCommands(world, batch)
	clear(&batch.additions)
	clear(&batch.addQueue)
}

@(private)
addInternal :: proc(world: ^World, entityId: u32, components: []Component) -> u32 {
	mask := computeMask(world, components)
	arch := getOrCreateArchetype(world, &mask)

	for &component in components {
		tid := reflect.union_variant_typeid(component)
		addToColumn(world, arch, tid, &component)
	}

	record := EntityRecord {
		archetype = arch,
		row       = len(arch.entities),
	}
	world.entities[entityId] = record
	append(&arch.entities, entityId)
	return 0
}

// TODO: this is broken for a mass-death event
@(private)
deleteInternal :: proc(world: ^World, entityId: u32) {
	record := getRecord(world, entityId)
	removeFromColumns(world, record.archetype, record.row)
	swapRecordRow(world, record.archetype, entityId)
	removeFromEntities(world, record.archetype, entityId)
}

@(private)
addComponentInternal :: proc(world: ^World, entityId: u32, component: Component) {
	record := getRecord(world, entityId)
	arch := record.archetype
	tid := reflect.union_variant_typeid(component)
	srcTids := getComponentsFromMask(&arch.mask)
	append(&srcTids, tid)
	dstMask := computeMask(world, srcTids[:])
	dstArch := getOrCreateArchetype(world, &dstMask)
	component := component

	moveData(world, arch, dstArch, record.row)
	addToColumn(world, dstArch, tid, &component)

	// Remove old record and swap row info
	swapRecordRow(world, arch, entityId)

	// Add new record
	newRecord := EntityRecord {
		archetype = dstArch,
		row       = len(dstArch.entities),
	}
	world.entities[entityId] = newRecord
	append(&dstArch.entities, entityId)
}

@(private)
deleteComponentInternal :: proc(world: ^World, entityId: u32, tid: typeid) {
	record := getRecord(world, entityId)
	arch := record.archetype
	srcTids := getComponentsFromMask(&arch.mask)

	found := false
	for srcTid, idx in srcTids {
		if srcTid == tid {
			found = true
			ordered_remove(&srcTids, idx)
			break
		}
	}

	if !found do return

	dstMask := computeMask(world, srcTids[:])
	dstArch := getOrCreateArchetype(world, &dstMask)
	moveData(world, arch, dstArch, record.row)

	// Remove old record and swap row info
	swapRecordRow(world, arch, entityId)

	// Add new record
	newRecord := EntityRecord {
		archetype = dstArch,
		row       = len(dstArch.entities),
	}
	world.entities[entityId] = newRecord
	append(&dstArch.entities, entityId)
}

@(private)
getNextId :: proc(world: ^World) -> u32 {
	if len(world.idQueue) == 0 {
		assert(world.nextId != MAX_ENTITIES + 1, "Tried to create more entities than allowed!")
		id := world.nextId
		world.nextId += 1
		return id
	}

	id := world.idQueue[0]
	ordered_remove(&world.idQueue, 0)
	return id
}
