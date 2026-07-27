package engine

import rl "vendor:raylib"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(engine: ^Engine) -> GameScene {
	sceneMan := engine.sceneManager
	texMan := engine.textureManager

	LoadTexture(engine, .PLAYER, "player.png")
	return {}
}

@(private)
loadGameScene :: proc(engine: ^Engine) {
	triggerSceneTransition(engine, .GAME)
}

@(private)
updateGameScene :: proc(engine: ^Engine) {
	// set data for current frame
}

@(private)
unloadGameScene :: proc(engine: ^Engine) {
	texMan := engine.textureManager
	for id, _ in texMan.data {
		UnloadTexture(engine, id)
	}
}

@(private)
drawGameScene :: proc(engine: ^Engine) {
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.RED,
		)
		tex, err := GetTexture(engine, .PLAYER)
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
