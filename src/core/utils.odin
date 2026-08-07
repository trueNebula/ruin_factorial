package core

import "src:log"
import rl "vendor:raylib"

RectAdd :: proc(r1: rl.Rectangle, r2: rl.Rectangle) -> rl.Rectangle {
	if r1.width != r2.width || r1.height != r2.height {
		log.Warn(
			"RectAdd assumes the rectangles have the same size and will use the size of the first one!",
		)
	}

	rect := rl.Rectangle {
		x      = r1.x + r2.x,
		y      = r1.y + r2.y,
		width  = r1.width,
		height = r2.height,
	}

	return rect
}

MoveRect :: proc(r: rl.Rectangle, offset: rl.Vector2) -> rl.Rectangle {
	return {x = r.x + offset.x, y = r.y + offset.y, width = r.width, height = r.height}
}

GetDestRect :: proc(t: Transform, s: Sprite) -> rl.Rectangle {
	rect := rl.Rectangle {
		x      = t.x,
		y      = t.y,
		width  = s.rect.width * t.sizeX,
		height = s.rect.height * t.sizeY,
	}

	return rect
}

Rect2Vec :: proc(r: rl.Rectangle) -> rl.Vector2 {
	return {r.x, r.y}
}

Rect2Size :: proc(r: rl.Rectangle) -> rl.Vector2 {
	return {r.width, r.height}
}

GetScreenCenter :: proc() -> rl.Vector2 {
	return {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)}
}
