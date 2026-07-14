package ecs

import "base:runtime"
import "core:fmt"
import "core:mem"
import "core:reflect"

Archetype :: struct {
	mask:     ComponentMask,
	entities: [dynamic]u32,
	columns:  map[typeid][dynamic]byte,
}

EntityRecord :: struct {
	archetype: ^Archetype,
	row:       int,
}

@(private)
getOrCreateArchetype :: proc(world: ^World, mask: ^ComponentMask) -> ^Archetype {
	for arch in world.archetypes {
		if arch.mask == mask^ {
			info := type_info_of(Component)
			#partial switch variant in info.variant.(runtime.Type_Info_Named).base.variant {
			case runtime.Type_Info_Union:
				for variantInfo, idx in variant.variants {
					if !maskIncludesOne(mask, idx) do continue

					if variantInfo.id not_in arch.columns {
						arch.columns[variantInfo.id] = make([dynamic]byte)
					}
				}
			}
			return arch
		}
	}

	arch := new(Archetype)
	arch.mask = mask^
	arch.entities = make([dynamic]u32)
	arch.columns = make(map[typeid][dynamic]byte)

	info := type_info_of(Component)
	#partial switch variant in info.variant {
	case runtime.Type_Info_Union:
		for variantInfo, idx in variant.variants {
			if !maskIncludesOne(mask, idx) do continue
			arch.columns[variantInfo.id] = make([dynamic]byte)
		}
	}

	append(&world.archetypes, arch)
	return arch
}

@(private)
addToColumn :: proc(world: ^World, arch: ^Archetype, tid: typeid, component: ^Component) {
	size := world.meta[tid].size
	column := arch.columns[tid]
	bufLen := len(column)

	resize(&column, bufLen + size)
	mem.copy(&column[bufLen], rawptr(component), size)
	arch.columns[tid] = column
}

@(private)
moveData :: proc(world: ^World, srcArch: ^Archetype, dstArch: ^Archetype, row: int) {
	srcComp := getComponentsFromMask(&srcArch.mask)
	dstComp := getComponentsFromMask(&dstArch.mask)

	for tid in srcComp {
		size := world.meta[tid].size
		start := row * size

		srcCol := srcArch.columns[tid]
		srcLen := len(srcCol)

		foundInDst := false
		for dstTid in dstComp {
			if tid == dstTid {
				foundInDst = true
				break
			}
		}

		if foundInDst {
			dstCol := dstArch.columns[tid]
			dstLen := len(dstCol)

			resize(&dstCol, dstLen + size)
			mem.copy(&dstCol[dstLen], &srcCol[start], size)

			dstArch.columns[tid] = dstCol
		}

		if start + size != srcLen {
			// mem.copy(&srcCol[start], &srcCol[start + size], srcLen - start - size)
			mem.copy(&srcCol[start], &srcCol[srcLen - size], size)
		}
		resize(&srcCol, srcLen - size)

		srcArch.columns[tid] = srcCol
	}
}

@(private)
batchMoveData :: proc(world: ^World, cmd: ^BatchAddCommand) {
	entityCount := len(cmd.entities)
	if entityCount == 0 do return

	src := cmd.src
	dst := cmd.dst
	srcComp := getComponentsFromMask(&cmd.src.mask)
	dstComp := getComponentsFromMask(&cmd.dst.mask)

	// Step 1: Shuffle entities to the end of the source archetype
	for i in 0 ..< entityCount {
		entityId := cmd.entities[i]
		currentRow := world.entities[entityId].row
		tailRow := len(src.entities) - 1 - i

		if currentRow >= tailRow do continue

		tailId := src.entities[tailRow]

		for tid in srcComp {
			size := world.meta[tid].size
			srcCol := src.columns[tid]

			buf: [256]byte
			mem.copy(&buf[0], &srcCol[tailRow * size], size)
			mem.copy(&srcCol[tailRow * size], &srcCol[currentRow * size], size)
			mem.copy(&srcCol[currentRow * size], &buf[0], size)
			src.columns[tid] = srcCol
		}

		src.entities[tailRow] = entityId
		src.entities[currentRow] = tailId

		if currentRecord, ok := &world.entities[entityId]; ok {
			currentRecord.row = tailRow
		}
		if tailRecord, ok := &world.entities[tailId]; ok {
			tailRecord.row = currentRow
		}
	}

	// Step 2: Allocate byte memory in destination columns
	dstStartRow := len(dst.entities)
	for tid in dstComp {
		size := world.meta[tid].size
		dstCol := dst.columns[tid]
		resize(&dstCol, len(dstCol) + (entityCount * size))
		dst.columns[tid] = dstCol
	}

	// Step 3: Blit shared component data from the packed tail of source to destination
	srcStartRow := len(src.entities) - entityCount
	for tid in srcComp {
		foundInDst := false
		for dstTid in dstComp {
			if tid == dstTid {
				foundInDst = true
				break
			}
		}

		if foundInDst {
			size := world.meta[tid].size
			srcCol := src.columns[tid]
			dstCol := dst.columns[tid]
			srcStart := &srcCol[srcStartRow * size]
			dstStart := &dstCol[dstStartRow * size]

			mem.copy(dstStart, srcStart, entityCount * size)
			dst.columns[tid] = dstCol
		}
	}

	// Step 4: Add new component payload data
	for tid, &compList in cmd.components {
		size := world.meta[tid].size
		dstCol := dst.columns[tid]

		for i in 0 ..< entityCount {
			unionComponent := &compList[i]
			dstRow := dstStartRow + i
			dstStart := &dstCol[dstRow * size]
			unionPtr := rawptr(unionComponent)

			mem.copy(dstStart, unionPtr, size)
		}
		dst.columns[tid] = dstCol
	}

	// Step 5: Append entity IDs to destination and update records
	for i in 0 ..< entityCount {
		entityId := src.entities[srcStartRow + i]
		dstRow := dstStartRow + i

		append(&dst.entities, entityId)
		world.entities[entityId] = EntityRecord {
			archetype = dst,
			row       = dstRow,
		}
	}

	// Step 6: Chop tail data off source archetype
	for tid in srcComp {
		size := world.meta[tid].size
		srcCol := src.columns[tid]
		resize(&srcCol, len(srcCol) - (entityCount * size))
		src.columns[tid] = srcCol
	}
	resize(&src.entities, len(src.entities) - entityCount)
}

@(private)
batchDeleteData :: proc(world: ^World, cmd: ^BatchDeleteCommand) {
	entityCount := len(cmd.entities)
	if entityCount == 0 do return

	src := cmd.src
	dst := cmd.dst
	srcComp := getComponentsFromMask(&cmd.src.mask)
	dstComp := getComponentsFromMask(&cmd.dst.mask)

	// Step 1: Shuffle entities to the end of the source archetype
	for i in 0 ..< entityCount {
		entityId := cmd.entities[i]
		currentRow := world.entities[entityId].row
		tailRow := len(src.entities) - 1 - i

		if currentRow >= tailRow do continue

		tailId := src.entities[tailRow]

		for tid in srcComp {
			size := world.meta[tid].size
			srcCol := src.columns[tid]

			buf: [256]byte
			mem.copy(&buf[0], &srcCol[tailRow * size], size)
			mem.copy(&srcCol[tailRow * size], &srcCol[currentRow * size], size)
			mem.copy(&srcCol[currentRow * size], &buf[0], size)
			src.columns[tid] = srcCol
		}

		src.entities[tailRow] = entityId
		src.entities[currentRow] = tailId

		if currentRecord, ok := &world.entities[entityId]; ok {
			currentRecord.row = tailRow
		}
		if tailRecord, ok := &world.entities[tailId]; ok {
			tailRecord.row = currentRow
		}
	}

	// Step 2: Allocate byte memory in destination columns
	dstStartRow := len(dst.entities)
	for tid in dstComp {
		size := world.meta[tid].size
		dstCol := dst.columns[tid]
		resize(&dstCol, len(dstCol) + (entityCount * size))
		dst.columns[tid] = dstCol
	}

	// Step 3: Blit surviving component data from the packed tail of source to destination
	srcStartRow := len(src.entities) - entityCount
	for tid in srcComp {
		foundInDst := false
		for dstTid in dstComp {
			if tid == dstTid {
				foundInDst = true
				break
			}
		}

		if foundInDst {
			size := world.meta[tid].size
			srcCol := src.columns[tid]
			dstCol := dst.columns[tid]
			srcStart := &srcCol[srcStartRow * size]
			dstStart := &dstCol[dstStartRow * size]

			mem.copy(dstStart, srcStart, entityCount * size)
			dst.columns[tid] = dstCol
		}
	}

	// Step 4: Append surviving entity IDs to destination and update records
	for i in 0 ..< entityCount {
		entityId := src.entities[srcStartRow + i]
		dstRow := dstStartRow + i

		if isMaskEmpty(&dst.mask) {
			delete_key(&world.entities, entityId)
		} else {
			append(&dst.entities, entityId)
			world.entities[entityId] = EntityRecord {
				archetype = dst,
				row       = dstRow,
			}
		}
	}

	// Step 5: Chop tail data off source archetype
	for tid in srcComp {
		size := world.meta[tid].size
		srcCol := src.columns[tid]
		resize(&srcCol, len(srcCol) - (entityCount * size))
		src.columns[tid] = srcCol
	}
	resize(&src.entities, len(src.entities) - entityCount)
}

@(private)
removeFromColumns :: proc(world: ^World, arch: ^Archetype, row: int) {
	tids := getComponentsFromMask(&arch.mask)

	for tid in tids {
		size := world.meta[tid].size
		start := row * size

		column := arch.columns[tid]
		bufLen := len(column)

		if start + size != bufLen {
			mem.copy(&column[start], &column[bufLen - size], size)
		}
		resize(&column, bufLen - size)

		arch.columns[tid] = column
	}
}

@(private)
removeFromEntities :: proc(world: ^World, arch: ^Archetype, entityId: u32) {
	for id, idx in arch.entities {
		if id == entityId {
			unordered_remove(&arch.entities, idx)
			break
		}
	}
}

@(private)
swapRecordRow :: proc(world: ^World, arch: ^Archetype, entityId: u32) {
	record := world.entities[entityId]
	lastIdx := len(arch.entities) - 1

	if record.row != lastIdx {
		lastEntity := arch.entities[lastIdx]

		if lastEntityRecord, ok := &world.entities[lastEntity]; ok {
			lastEntityRecord.row = record.row
		}
	}

	unordered_remove(&arch.entities, record.row)
}

// Unused
@(private)
setToColumn :: proc(world: ^World, entityId: u32, component: ^Component) {
	tid := reflect.union_variant_typeid(component)
	record := world.entities[entityId]
	arch := record.archetype
	column := arch.columns[tid]
	size := world.meta[tid].size
	start := record.row * size

	mem.copy(&column[start], rawptr(component), size)
}

@(private)
getComponentData :: proc(
	world: ^World,
	arch: ^Archetype,
	tid: typeid,
	idx: int,
) -> (
	data: rawptr,
	err: bool,
) {
	if tid not_in arch.columns {
		return nil, true
	}

	column, ok := arch.columns[tid]
	size := world.meta[tid].size
	start := size * idx
	return rawptr(&column[start]), false
}

@(private)
getComponent :: proc(world: ^World, entityId: u32, $T: typeid) -> (component: ^T, err: bool) {
	record := world.entities[entityId]
	data, dataErr := getComponentData(world, record.archetype, T, record.row)
	if dataErr {
		return nil, true
	}
	return (^T)(data), false
}

@(private)
getRecord :: proc(world: ^World, entityId: u32) -> EntityRecord {
	return world.entities[entityId]
}
