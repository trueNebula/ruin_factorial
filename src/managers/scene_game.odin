package managers

import rl "vendor:raylib"

GameScene :: struct {}

@(private)
loadGameScene :: proc(manager: ^SceneManager) {
	triggerSceneTransition(manager, .GAME)
}

@(private)
updateGameScene :: proc(manager: ^SceneManager) {
	// set data for current frame
}

@(private)
drawGameScene :: proc(manager: ^SceneManager) {
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.RED,
		)
	}
}
