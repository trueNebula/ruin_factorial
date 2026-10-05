package layout

import rl "vendor:raylib"

Padding :: proc(rect: rl.Rectangle, padding: f32) -> rl.Rectangle {
	return {
		x = rect.x + padding,
		y = rect.y + padding,
		width = rect.width - padding * 2,
		height = rect.height - padding * 2,
	}
}
