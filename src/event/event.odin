package event

import "src:core"

Event :: union {
	GenerateBlocks,
	GenerateWorld,
	ClearTilemap,
	Collision,
	Interact,
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
	onLayer:       core.ColliderLayer,
}
Pickup :: struct {
	collector: u32,
	item:      u32,
}
Interact :: struct {
	input:       ^core.Inventory,
	output:      ^core.Inventory,
	blockConfig: core.BlockConfig,
	entity:      u32,
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
