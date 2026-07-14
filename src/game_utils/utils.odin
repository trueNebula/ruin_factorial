package utils

import rl "vendor:raylib"

vec2 :: rl.Vector2
path :: string

WindowProps :: struct {
	width:     i32,
	height:    i32,
	title:     cstring,
	minWidth:  i32,
	minHeight: i32,
}

WindowDefaults: WindowProps = {
	width     = 1280,
	height    = 720,
	title     = "Ruin! Factorial - v0.0.0.1",
	minWidth  = 640,
	minHeight = 360,
}

fullscreenManager :: proc() {
	if (rl.IsKeyPressed(rl.KeyboardKey.F11)) {
		rl.ToggleBorderlessWindowed()
	}
}
