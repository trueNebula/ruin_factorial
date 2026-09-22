package event

import "src:core"

Event :: union {
	GenerateBlocks,
	GenerateWorld,
	ClearTilemap,
	Collision,
	Pickup,
}

GenerateWorld :: struct {}
GenerateBlocks :: struct {}
ClearTilemap :: struct {}
Collision :: struct {
	self:          u32,
	other:         u32,
	selfIsPlayer:  bool,
	otherIsPlayer: bool,
	onLayers:      core.CollisionLayers,
}
Pickup :: struct {
	collector: u32,
	item:      u32,
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
