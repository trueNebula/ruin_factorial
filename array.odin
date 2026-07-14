package structure

arrayIncludes :: proc(array: []$T, value: T) -> bool {
	for i in array {
		if i == value do return true
	}

	return false
}

dynamicArrayIncludes :: proc(slice: [dynamic]$T, value: T) -> bool {
	for i in array {
		if i == value do return true
	}

	return false
}
