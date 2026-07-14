package ecs

import manager "src:managers"
import rl "vendor:raylib"

EntityRef :: struct {
	id:  u32,
	gen: u32,
}

Transform :: struct {
	x, y:         f32,
	rotation:     f32,
	sizeX, sizeY: f32,
}

Sprite :: struct {
	texture: manager.Texture,
	rect:    rl.Rectangle,
}
