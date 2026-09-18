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
	texture:          Texture,
	rect:             rl.Rectangle,
	anchor:           Anchor,
	offsetX, offsetY: f32,
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

Camera :: struct {
	camera: rl.Camera2D,
}

Item :: struct {
	id:    ItemId,
	count: u16,
}

Inventory :: struct {
	slots: []Item,
	size:  int,
}

Health :: struct {
	current: int,
	max:     int,
}

Tint :: rl.Color

TintTween :: struct {
	destination: rl.Color,
	duration:    f32,
	timer:       f32,
	curve:       TweenCurve,
	reverse:     bool,
}

Drop :: struct {
	item:   ItemId,
	qty:    RangeInt,
	weight: i32,
}

DropTable :: struct {
	drops: []Drop,
}

Float :: struct {
	amplitude: f32,
	frequency: f32, // Hz
	timer:     f32,
}
