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

GetDestRect :: proc(t: Transform, s: Sprite) -> rl.Rectangle {
	rect := rl.Rectangle {
		x      = t.x,
		y      = t.y,
		width  = s.rect.width * t.sizeX,
		height = s.rect.height * t.sizeY,
	}

	return rect
}
