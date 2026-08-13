package main

import "src:core"
import "src:engine"
import "src:log"
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.SetExitKey(.KEY_NULL)
	rl.InitWindow(core.WindowDefaults.width, core.WindowDefaults.height, core.WindowDefaults.title)
	rl.SetWindowMinSize(core.WindowDefaults.minWidth, core.WindowDefaults.minHeight)
	defer rl.CloseWindow()

	log.Init()
	Engine := engine.MakeEngine()
	engine.Run(&Engine)
	engine.Shutdown(&Engine)
	log.Shutdown()
}
