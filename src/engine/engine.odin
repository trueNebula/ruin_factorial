package engine

import "src:core"
import "src:ecs"
import "src:input"
import "src:player"
import "src:scene"
import "src:texture"
import rl "vendor:raylib"

Engine :: struct {
	sceneManager:   ^scene.SceneManager,
	textureManager: ^texture.TextureManager,
	world:          ^ecs.World,
	frameInput:     input.State,
}

MakeEngine :: proc() -> Engine {
	texMan := new(texture.TextureManager)
	texMan^ = texture.MakeTextureManager()

	world := new(ecs.World)
	world^ = ecs.CreateWorld()

	sceneMan := new(scene.SceneManager)
	sceneMan^ = scene.MakeSceneManger(texMan, world)

	engine := Engine {
		sceneManager   = sceneMan,
		textureManager = texMan,
		world          = world,
	}

	return engine
}

Init :: proc(engine: ^Engine) {
	scene.LoadFirstScene(engine.sceneManager)
}

Run :: proc(engine: ^Engine) {
	for !rl.WindowShouldClose() {
		core.FullscreenManager()

		engine.frameInput = input.Poll(core.DefaultKeybinds)
		scene.Input(engine.sceneManager)

		update(engine)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		switch engine.sceneManager.current {
		case .MENU:
		// TODO: add menu scene rendering
		case .GAME:
			playerView := ecs.View2(engine.world, core.PlayerRef, core.Camera)
			if len(playerView) == 0 {
				// No camera set up yet, skip rendering
				break
			}
			camera := playerView[0].c2
			rl.BeginMode2D(camera.camera)
			ecs.ProcessRender(engine.world, engine.textureManager)
			rl.EndMode2D()
		}

		scene.DrawTransition(engine.sceneManager)
		rl.EndDrawing()

		ecs.FrameEnd(engine.world)
	}
}

Shutdown :: proc(engine: ^Engine) {
	ecs.EndWorld(engine.world)
	texture.Shutdown(engine.textureManager)
}

@(private)
update :: proc(engine: ^Engine) {
	scene.Update(engine.sceneManager)
	player.PlayerInputSystem(engine.world, &engine.frameInput)
	ecs.ProcessTick(engine.world)
}
