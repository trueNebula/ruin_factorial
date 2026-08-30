package ecs

import "core:reflect"
ComponentSet :: struct {
	data:   [dynamic]^Component,
	lookup: map[typeid]int,
}

MakeComponentSet :: proc {
	componentSetMakeEmpty,
}

ComponentSetAdd :: proc {
	componentSetAdd,
}

ComponentSetGet :: proc {
	componentSetGet,
}

Cleanup :: proc {
	componentSetCleanup,
}

@(private = "file")
componentSetMakeEmpty :: proc(allocator := context.allocator) -> ComponentSet {
	return ComponentSet{data = make([dynamic]^Component), lookup = make(map[typeid]int)}
}

@(private = "file")
componentSetAdd :: proc(set: ^ComponentSet, values: ..^Component) -> (inserted: bool) {
	added := false
	for value in values {
		tid := reflect.union_variant_typeid(value^)
		if tid not_in set.lookup {
			set.lookup[tid] = len(set.data)
			append(&set.data, value)
			added = true
		}
	}
	return added
}

@(private = "file")
@(require_results)
componentSetGet :: proc(set: ^ComponentSet, tid: typeid) -> (data: ^Component, err: bool) {
	if tid not_in set.lookup {
		return nil, true
	}

	idx := set.lookup[tid]
	return set.data[idx], false
}

@(private = "file")
componentSetCleanup :: proc(set: ^ComponentSet) {
	delete(set.data)
	delete(set.lookup)
}
