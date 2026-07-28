package scene

import t "src:texture"
import rl "vendor:raylib"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(sceneMan: ^SceneManager) -> GameScene {
	texMan := sceneMan.textureManager
	t.LoadTexture(texMan, .PLAYER, "player.png")
	return {}
}

@(private)
loadGameScene :: proc(sceneMan: ^SceneManager) {
	triggerSceneTransition(sceneMan, .GAME)
}

@(private)
updateGameScene :: proc(sceneMan: ^SceneManager) {
	// set data for current frame
}

@(private)
unloadGameScene :: proc(sceneMan: ^SceneManager) {
	texMan := sceneMan.textureManager
	for id, _ in texMan.data {
		t.UnloadTexture(texMan, id)
	}
}

@(private)
drawGameScene :: proc(sceneMan: ^SceneManager) {
	texMan := sceneMan.textureManager
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.RED,
		)
		tex, err := t.GetTexture(texMan, .PLAYER)
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
