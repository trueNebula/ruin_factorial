package scene

import "src:ecs"
import "src:physics"
import "src:player"
import "src:render"
import t "src:texture"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(sceneMan: ^SceneManager) -> GameScene {
	renMan := sceneMan.renderManager
	texMan := sceneMan.textureManager
	world := sceneMan.world
	t.LoadTexture(texMan, .PLAYER, "player.png")
	t.LoadTexture(texMan, .TILE, "tile_atlas.png")

	ecs.RegisterSetupSystem(world, player.SetupPlayer)
	ecs.RegisterTickSystem(world, player.PlayerMovementSystem)
	ecs.RegisterTickSystem(world, physics.MovementSystem)
	ecs.RegisterTickSystem(world, player.CameraTransformSystem)
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
