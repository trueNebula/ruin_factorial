package core

import rl "vendor:raylib"

EntityRef :: struct {
	id:  u32,
	gen: u32,
}

PlayerRef :: struct {
	id: u32,
}

Transform :: struct {
	x, y:         f32,
	rotation:     f32,
	sizeX, sizeY: f32,
}

Velocity :: rl.Vector2

Sprite :: struct {
	texture: Texture,
	rect:    rl.Rectangle,
	anchor:  Anchor,
}

AnimationFrame :: struct {
	rect:     rl.Rectangle,
	duration: f32,
}

Animation :: struct {
	frames: []AnimationFrame,
	index:  int,
	timer:  f32,
}

Tint :: struct {
	start:    rl.Color,
	dest:     rl.Color,
	timer:    f32,
	duration: f32,
}

Camera :: struct {
	camera: rl.Camera2D,
}

InventorySlot :: struct {
	item:  ItemId,
	count: u16,
}

Inventory :: struct {
	slots: []InventorySlot,
	size:  int,
}
