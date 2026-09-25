package scene

import "src:ecs"
import "src:event"
import "src:item"
import "src:physics"
import "src:player"
import "src:render"
import t "src:texture"
import "src:ui"

GameScene :: struct {
	// Game state goes here
}

@(private)
initGameScene :: proc(sceneMan: ^SceneManager) -> GameScene {
	texMan := sceneMan.textureManager
	world := sceneMan.world
	queue := sceneMan.queue
	uiMan := sceneMan.ui

	t.LoadTexture(texMan, .PLAYER, "player.png")
	t.LoadTexture(texMan, .TILE, "tile_atlas.png")
	t.LoadTexture(texMan, .ITEM, "item_atlas.png")
	t.LoadTexture(texMan, .BLOCK, "block_atlas.png")

	ui.RegisterComponent(uiMan, .HOTBAR, ui.HotbarState{slots = {}, size = 10, selected = 0})

	event.PushEvent(queue, event.GenerateWorld{})
	event.PushEvent(queue, event.GenerateBlocks{})

	ecs.RegisterSetupSystem(world, player.SetupPlayer)
	ecs.RegisterTickSystem(world, player.PlayerMovementSystem)
	ecs.RegisterTickSystem(world, physics.MovementSystem)
	ecs.RegisterTickSystem(world, player.CameraTransformSystem)
	ecs.RegisterTickSystem(world, render.ApplyTintTween)
	ecs.RegisterTickSystem(world, item.FloatItem)
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
	world := sceneMan.world
	for id, _ in texMan.data {
		t.UnloadTexture(texMan, id)
	}

	ecs.ClearWorld(world)
	event.PushEvent(sceneMan.queue, event.ClearTilemap{})
}
