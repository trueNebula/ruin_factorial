package main

import u "game_utils"
import m "src:managers"
import rl "vendor:raylib"

main :: proc() {
	rl.SetWindowState({.WINDOW_RESIZABLE})
	rl.InitWindow(u.WindowDefaults.width, u.WindowDefaults.height, u.WindowDefaults.title)
	rl.SetWindowMinSize(u.WindowDefaults.minWidth, u.WindowDefaults.minHeight)
	defer rl.CloseWindow()

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
		zoom     = 2.0,
		rotation = 0.0,
	}

	sceneManager := m.MakeSceneManger()

	for !rl.WindowShouldClose() {
		u.fullscreenManager()

		m.InputScene(&sceneManager)
		m.UpdateScene(&sceneManager)
		m.DrawScene(&sceneManager)
	}
}
