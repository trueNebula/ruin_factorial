package structure

Stack :: struct($T: typeid) {
	data: [dynamic]T,
}

@(private)
stackMakeEmpty :: proc($T: typeid, allocator := context.allocator) -> Stack(T) {
	return Stack(T){data = make([dynamic]T, allocator)}
}

@(private)
stackMakeFromSlice :: proc(values: ..$T, allocator := context.allocator) -> Stack(T) {
	stack := Stack(T) {
		data = make([dynamic]T, allocator),
	}
	for value in values {
		append(&stack.data, value)
	}
	return stack
}

@(private)
stackDelete :: proc(stack: ^Stack($T)) {
	delete(stack.data)
	stack^ = {}
}

@(private)
stackPush :: proc(stack: ^Stack($T), values: ..T) {
	for value in values {
		append(&stack.data, value)
	}
}

@(private)
stackPop :: proc(stack: ^Stack($T)) -> T {
	lastIdx := len(stack.data) - 1
	value := stack.data[lastIdx]
	unordered_remove(&stack.data, lastIdx)
	return value
}

@(private)
stackPeek :: proc(stack: ^Stack($T)) -> T {
	assert(len(stack.data) > 0, "Tried to peek at an empty stack!")
	return stack.data[len(stack.data) - 1]
}

@(private)
stackIncludes :: proc(stack: ^Stack($T), value: T) -> bool {
	for val in stack.data {
		if val == value do return true
	}
	return false
}

@(private)
stackEmpty :: proc(stack: ^Stack($T)) -> bool {
	return len(stack.data) == 0
}

@(private)
stackLength :: proc(stack: ^Stack($T)) -> int {
	return len(stack.data)
}
