package ecs

import "base:runtime"
import "core:fmt"

/**
 * Entity Views
 * Returns a list of entityID - components structs
 */
EntityView1 :: struct($T1: typeid) {
	id: u32,
	c1: ^T1,
}

View1 :: proc(world: ^World, $T1: typeid) -> [dynamic]EntityView1(T1) {
	tids := []typeid{typeid_of(T1)}
	mask := computeMask(world, tids)
	views := make([dynamic]EntityView1(T1), context.temp_allocator)

	for arch in world.archetypes {
		if !maskIncludes(&arch.mask, &mask) do continue

		col1 := arch.columns[T1]

		size1 := world.meta[T1].size

		for entId, entIdx in arch.entities {
			view: EntityView1(T1)
			view.id = entId
			view.c1 = (^T1)(&col1[entIdx * size1])

			append(&views, view)
		}
	}

	return views
}

EntityView2 :: struct($T1: typeid, $T2: typeid) {
	id: u32,
	c1: ^T1,
	c2: ^T2,
}

View2 :: proc(world: ^World, $T1: typeid, $T2: typeid) -> [dynamic]EntityView2(T1, T2) {
	tids := []typeid{typeid_of(T1), typeid_of(T2)}
	mask := computeMask(world, tids)
	views := make([dynamic]EntityView2(T1, T2), context.temp_allocator)

	for arch in world.archetypes {
		if !maskIncludes(&arch.mask, &mask) do continue

		col1 := arch.columns[T1]
		col2 := arch.columns[T2]

		size1 := world.meta[T1].size
		size2 := world.meta[T2].size

		for entId, entIdx in arch.entities {
			view: EntityView2(T1, T2)
			view.id = entId
			view.c1 = (^T1)(&col1[entIdx * size1])
			view.c2 = (^T2)(&col2[entIdx * size2])

			append(&views, view)
		}
	}

	return views
}

EntityView3 :: struct($T1: typeid, $T2: typeid, $T3: typeid) {
	id: u32,
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
}

View3 :: proc(
	world: ^World,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
) -> [dynamic]EntityView3(T1, T2, T3) {
	tids := []typeid{typeid_of(T1), typeid_of(T2), typeid_of(T3)}
	mask := computeMask(world, tids)

	views := make([dynamic]EntityView3(T1, T2, T3), context.temp_allocator)

	for arch in world.archetypes {
		if !maskIncludes(&arch.mask, &mask) do continue

		col1 := arch.columns[T1]
		col2 := arch.columns[T2]
		col3 := arch.columns[T3]

		size1 := world.meta[T1].size
		size2 := world.meta[T2].size
		size3 := world.meta[T3].size

		for entId, entIdx in arch.entities {
			view: EntityView3(T1, T2, T3)
			view.id = entId

			view.c1 = (^T1)(&col1[entIdx * size1])
			view.c2 = (^T2)(&col2[entIdx * size2])
			view.c3 = (^T3)(&col3[entIdx * size3])

			append(&views, view)
		}
	}

	return views
}

EntityView4 :: struct($T1: typeid, $T2: typeid, $T3: typeid, $T4: typeid) {
	id: u32,
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
	c4: ^T4,
}

View4 :: proc(
	world: ^World,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
	$T4: typeid,
) -> [dynamic]EntityView4(T1, T2, T3, T4) {
	tids := []typeid{typeid_of(T1), typeid_of(T2), typeid_of(T3), typeid_of(T4)}
	mask := computeMask(world, tids)

	views := make([dynamic]EntityView4(T1, T2, T3, T4), context.temp_allocator)

	for arch in world.archetypes {
		if !maskIncludes(&arch.mask, &mask) do continue

		col1 := arch.columns[T1]
		col2 := arch.columns[T2]
		col3 := arch.columns[T3]
		col4 := arch.columns[T4]

		size1 := world.meta[T1].size
		size2 := world.meta[T2].size
		size3 := world.meta[T3].size
		size4 := world.meta[T4].size

		for entId, entIdx in arch.entities {
			view: EntityView4(T1, T2, T3, T4)
			view.id = entId

			view.c1 = (^T1)(&col1[entIdx * size1])
			view.c2 = (^T2)(&col2[entIdx * size2])
			view.c3 = (^T3)(&col3[entIdx * size3])
			view.c4 = (^T4)(&col4[entIdx * size4])

			append(&views, view)
		}
	}

	return views
}

EntityView5 :: struct($T1: typeid, $T2: typeid, $T3: typeid, $T4: typeid, $T5: typeid) {
	id: u32,
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
	c4: ^T4,
	c5: ^T5,
}

View5 :: proc(
	world: ^World,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
	$T4: typeid,
	$T5: typeid,
) -> [dynamic]EntityView5(T1, T2, T3, T4, T5) {
	tids := []typeid{typeid_of(T1), typeid_of(T2), typeid_of(T3), typeid_of(T4), typeid_of(T5)}
	mask := computeMask(world, tids)

	views := make([dynamic]EntityView5(T1, T2, T3, T4, T5), context.temp_allocator)

	for arch in world.archetypes {
		if !maskIncludes(&arch.mask, &mask) do continue

		col1 := arch.columns[T1]
		col2 := arch.columns[T2]
		col3 := arch.columns[T3]
		col4 := arch.columns[T4]
		col5 := arch.columns[T5]

		size1 := world.meta[T1].size
		size2 := world.meta[T2].size
		size3 := world.meta[T3].size
		size4 := world.meta[T4].size
		size5 := world.meta[T5].size

		for entId, entIdx in arch.entities {
			view: EntityView5(T1, T2, T3, T4, T5)
			view.id = entId

			view.c1 = (^T1)(&col1[entIdx * size1])
			view.c2 = (^T2)(&col2[entIdx * size2])
			view.c3 = (^T3)(&col3[entIdx * size3])
			view.c4 = (^T4)(&col4[entIdx * size4])
			view.c5 = (^T5)(&col5[entIdx * size5])

			append(&views, view)
		}
	}

	return views
}

/**
 * Single Entity Views
 * Returns a single struct containing requested components for
 * a given entity ID
 */
SingleEntityView1 :: struct($T1: typeid) {
	c1: ^T1,
}

SingleView1 :: proc(world: ^World, entityId: u32, $T1: typeid) -> SingleEntityView1(T1) {
	record := getRecord(world, entityId)
	arch := record.archetype
	row := record.row

	col1 := arch.columns[T1]

	size1 := world.meta[T1].size

	view := SingleEntityView1(T1) {
		c1 = (^T1)(&col1[row * size1]),
	}

	return view
}

SingleEntityView2 :: struct($T1: typeid, $T2: typeid) {
	c1: ^T1,
	c2: ^T2,
}

SingleView2 :: proc(
	world: ^World,
	entityId: u32,
	$T1: typeid,
	$T2: typeid,
) -> SingleEntityView2(T1, T2) {
	record := getRecord(world, entityId)
	arch := record.archetype
	row := record.row

	col1 := arch.columns[T1]
	col2 := arch.columns[T2]

	size1 := world.meta[T1].size
	size2 := world.meta[T2].size

	view := SingleEntityView2(T1, T2) {
		c1 = (^T1)(&col1[row * size1]),
		c2 = (^T2)(&col2[row * size2]),
	}

	return view
}

SingleEntityView3 :: struct($T1: typeid, $T2: typeid, $T3: typeid) {
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
}

SingleView3 :: proc(
	world: ^World,
	entityId: u32,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
) -> SingleEntityView3(T1, T2, T3) {
	record := getRecord(world, entityId)
	arch := record.archetype
	row := record.row

	col1 := arch.columns[T1]
	col2 := arch.columns[T2]
	col3 := arch.columns[T3]

	size1 := world.meta[T1].size
	size2 := world.meta[T2].size
	size3 := world.meta[T3].size

	view := SingleEntityView3(T1, T2, T3) {
		c1 = (^T1)(&col1[row * size1]),
		c2 = (^T2)(&col2[row * size2]),
		c3 = (^T3)(&col3[row * size3]),
	}

	return view
}

SingleEntityView4 :: struct($T1: typeid, $T2: typeid, $T3: typeid, $T4: typeid) {
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
	c4: ^T4,
}

SingleView4 :: proc(
	world: ^World,
	entityId: u32,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
	$T4: typeid,
) -> SingleEntityView4(T1, T2, T3, T4) {
	record := getRecord(world, entityId)
	arch := record.archetype
	row := record.row

	col1 := arch.columns[T1]
	col2 := arch.columns[T2]
	col3 := arch.columns[T3]
	col4 := arch.columns[T4]

	size1 := world.meta[T1].size
	size2 := world.meta[T2].size
	size3 := world.meta[T3].size
	size4 := world.meta[T4].size

	view := SingleEntityView4(T1, T2, T3, T4) {
		c1 = (^T1)(&col1[row * size1]),
		c2 = (^T2)(&col2[row * size2]),
		c3 = (^T3)(&col3[row * size3]),
		c4 = (^T4)(&col4[row * size4]),
	}

	return view
}

SingleEntityView5 :: struct($T1: typeid, $T2: typeid, $T3: typeid, $T4: typeid, $T5: typeid) {
	c1: ^T1,
	c2: ^T2,
	c3: ^T3,
	c4: ^T4,
	c5: ^T5,
}

SingleView5 :: proc(
	world: ^World,
	entityId: u32,
	$T1: typeid,
	$T2: typeid,
	$T3: typeid,
	$T4: typeid,
	$T5: typeid,
) -> SingleEntityView5(T1, T2, T3, T4, T5) {
	record := getRecord(world, entityId)
	arch := record.archetype
	row := record.row

	col1 := arch.columns[T1]
	col2 := arch.columns[T2]
	col3 := arch.columns[T3]
	col4 := arch.columns[T4]
	col5 := arch.columns[T5]

	size1 := world.meta[T1].size
	size2 := world.meta[T2].size
	size3 := world.meta[T3].size
	size4 := world.meta[T4].size
	size5 := world.meta[T5].size

	view := SingleEntityView5(T1, T2, T3, T4, T5) {
		c1 = (^T1)(&col1[row * size1]),
		c2 = (^T2)(&col2[row * size2]),
		c3 = (^T3)(&col3[row * size3]),
		c4 = (^T4)(&col4[row * size4]),
		c5 = (^T5)(&col5[row * size5]),
	}

	return view
}
