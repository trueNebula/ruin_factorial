package event

Event :: union {
	GenerateBlocks,
	GenerateWorld,
	ClearTilemap,
}

GenerateWorld :: struct {}
GenerateBlocks :: struct {}
ClearTilemap :: struct {}

Queue :: struct {
	items: [dynamic]Event,
}

MakeQueue :: proc() -> Queue {
	return {items = make([dynamic]Event)}
}

PushEvent :: proc(queue: ^Queue, event: Event) {
	append(&queue.items, event)
}
