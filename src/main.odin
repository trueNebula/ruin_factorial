package main

import "src:core"
import "src:engine"
import "src:log"
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.InitWindow(core.WindowDefaults.width, core.WindowDefaults.height, core.WindowDefaults.title)
	rl.SetWindowMinSize(core.WindowDefaults.minWidth, core.WindowDefaults.minHeight)
	defer rl.CloseWindow()

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
		zoom     = 2.0,
		rotation = 0.0,
	}

	log.Init()
	Engine := engine.MakeEngine()
	engine.Run(&Engine)
	log.Shutdown()
}
