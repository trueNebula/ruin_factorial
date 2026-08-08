package scene

import "src:ecs"
import "src:physics"
import "src:render"
import t "src:texture"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(sceneMan: ^SceneManager) -> GameScene {
	texMan := sceneMan.textureManager
	world := sceneMan.world
	t.LoadTexture(texMan, .PLAYER, "player.png")

	ecs.RegisterSetupSystem(world, SetupPlayer)
	ecs.RegisterTickSystem(world, physics.MovementSystem)
	ecs.RegisterRenderSystem(world, render.RenderSprites)
	ecs.ProcessSetup(world)

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
