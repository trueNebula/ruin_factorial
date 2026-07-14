package structure

Queue :: struct($T: typeid) {
	data: [dynamic]T,
}

@(private)
queueMakeEmpty :: proc($T: typeid, allocator := context.allocator) -> Queue(T) {
	return Queue(T){data = make([dynamic]T, allocator)}
}

@(private)
queueMakeFromSlice :: proc(values: ..$T, allocator := context.allocator) -> Queue(T) {
	queue := Queue(T) {
		data = make([dynamic]T, allocator),
	}
	for value in values {
		append(&queue.data, value)
	}
	return queue
}

@(private)
queueDelete :: proc(queue: ^Queue($T)) {
	delete(queue.data)
	queue^ = {}
}

@(private)
queuePush :: proc(queue: ^Queue($T), values: ..T) {
	for value in values {
		append(&queue.data, value)
	}
}

@(private)
queuePop :: proc(queue: ^Queue($T)) -> T {
	assert(len(queue.data) > 0, "Tried to pop from an empty queue!")
	value := queue.data[0]
	ordered_remove(&queue.data, 0)
	return value
}

@(private)
queueFront :: proc(queue: ^Queue($T)) -> T {
	assert(len(queue.data) > 0, "Tried to get front of an empty queue!")
	return queue.data[0]
}

@(private)
queueBack :: proc(queue: ^Queue($T)) -> T {
	assert(len(queue.data) > 0, "Tried to get back of an empty queue!")
	return queue.data[len(queue.data) - 1]
}

@(private)
queueIncludes :: proc(queue: ^Queue($T), value: T) -> bool {
	for val in queue.data {
		if val == value do return true
	}
	return false
}

@(private)
queueEmpty :: proc(queue: ^Queue($T)) -> bool {
	return len(queue.data) == 0
}

@(private)
queueLength :: proc(queue: ^Queue($T)) -> int {
	return len(queue.data)
}
