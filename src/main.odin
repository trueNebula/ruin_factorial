package main

import u "game_utils"
import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(640, 480, "ruin!Factorial")
	rl.SetWindowState({.WINDOW_RESIZABLE})
	defer rl.CloseWindow()

	camera := rl.Camera2D {
		target   = {0, 0},
		offset   = {f32(rl.GetScreenWidth() / 2), f32(rl.GetScreenHeight() / 2)},
		zoom     = 2.0,
		rotation = 0.0,
	}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.BeginMode2D(camera)
		{
			rl.DrawTriangle(u.vec2{32, 32}, u.vec2{0, -64}, u.vec2{-32, 32}, rl.GREEN)
		}
		rl.EndMode2D()
		rl.EndDrawing()

	}
}
