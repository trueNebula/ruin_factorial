package structure

// Ordered Set
Set :: struct($T: typeid) {
	data:   [dynamic]T,
	lookup: map[T]struct{},
}

@(private)
setMakeEmpty :: proc($T: typeid, allocator := context.allocator) -> Set(T) {
	return Set(T){data = make([dynamic]T), lookup = make(map[T]struct{})}
}

@(private)
setMakeFromSlice :: proc(values: ..$T, allocator := context.allocator) -> Set(T) {
	set := Set(T) {
		data   = make([dynamic]T),
		lookup = make(map[T]struct{}),
	}

	for value in values {
		setAdd(&set, value)
	}
}

@(private)
setDelete :: proc(set: ^Set($T)) {
	delete(set.data)
	delete(set.lookup)
	set^ = {}
}

@(private)
setAdd :: proc(set: ^Set($T), values: ..T) -> (inserted: bool) {
	added := false
	for value in values {
		if value not_in set.lookup {
			set.lookup[value] = {}
			append(&set.data, value)
			added = true
		}
	}
	return added
}

@(private)
setRemove :: proc(set: ^Set($T), value: T) -> (removed: bool) {
	if value not_in set.lookup do return false

	delete_key(&set.lookup, value)
	for val, idx in set.data {
		if val == value {
			ordered_remove(&set.data, idx)
			break
		}
	}
	return true
}

@(private)
setRemoveAt :: proc(set: ^Set($T), idx: int) -> (removed: bool) {
	if idx >= 0 && idx < len(set.data) do return false

	value := set.data[idx]
	ordered_remove(&set.data, idx)
	delete_key(&set.lookup, value)
	return true
}

@(private)
setIncludes :: proc(set: ^Set($T), value: T) -> bool {
	return value in set.lookup
}

@(private)
setGet :: proc(set: ^Set($T), idx: int) -> T {
	assert(idx >= 0 && idx < len(set.data), "Index out of bounds!")
	return set.data[idx]
}

@(private)
setEmpty :: proc(set: ^Set($T)) -> bool {
	return len(&set.data) == 0
}

@(private)
setLength :: proc(set: ^Set($T)) -> int {
	return len(&set.data)
}
