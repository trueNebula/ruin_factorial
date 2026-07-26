package managers

import rl "vendor:raylib"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(manager: ^SceneManager) -> GameScene {
	texMan := manager.textureManager

	LoadTexture(texMan, .PLAYER, "player.png")
	return {}
}

@(private)
loadGameScene :: proc(manager: ^SceneManager) {
	triggerSceneTransition(manager, .GAME)
}

@(private)
updateGameScene :: proc(manager: ^SceneManager) {
	// set data for current frame
}

@(private)
unloadGameScene :: proc(manager: ^SceneManager) {
	texMan := manager.textureManager
	for id, _ in texMan.data {
		UnloadTexture(texMan, id)
	}
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
		tex, err := GetTexture(manager.textureManager, .PLAYER)
		if err do return
		rl.DrawTexturePro(
			tex,
			{x = 0, y = 0, width = 16, height = 16},
			{
				x = f32(rl.GetScreenWidth()) / 2 - 8,
				y = f32(rl.GetScreenHeight()) / 2 - 8,
				width = 16,
				height = 16,
			},
			{0, 0},
			0,
			rl.WHITE,
		)
	}
}
