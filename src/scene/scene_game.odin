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
