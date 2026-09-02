package event

Event :: union {
	GenerateWorld,
	ClearTilemap,
}

GenerateWorld :: struct {
	seed: u64,
}

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
