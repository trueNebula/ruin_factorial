package event

import "src:core"
Event :: union {
	GenerateBlocks,
	GenerateWorld,
	ClearTilemap,
	Collision,
}

GenerateWorld :: struct {}
GenerateBlocks :: struct {}
ClearTilemap :: struct {}
Collision :: struct {
	entity:           u32,
	collider:         u32,
	entityIsPlayer:   bool,
	colliderIsPlayer: bool,
}

Queue :: struct {
	items: [dynamic]Event,
}

MakeQueue :: proc() -> Queue {
	return {items = make([dynamic]Event)}
}

PushEvent :: proc(queue: ^Queue, event: Event) {
	append(&queue.items, event)
}
