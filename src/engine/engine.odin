package engine

import "src:core"
import "src:ecs"
import "src:input"
import "src:log"
import "src:player"
import "src:render"
import "src:scene"
import "src:texture"
import "src:tilemap"
import rl "vendor:raylib"

Engine :: struct {
	sceneManager:   ^scene.SceneManager,
	renderManager:  ^render.RenderManager,
	textureManager: ^texture.TextureManager,
	tileManager:    ^tilemap.TileManager,
	world:          ^ecs.World,
	frameInput:     input.State,
}

MakeEngine :: proc() -> Engine {
	texMan := new(texture.TextureManager)
	texMan^ = texture.MakeTextureManager()

	world := new(ecs.World)
	world^ = ecs.CreateWorld()

	renMan := new(render.RenderManager)
	renMan^ = render.MakeRenderManager()

	tileMan := new(tilemap.TileManager)
	tileMan^ = tilemap.MakeTileManager()

	sceneMan := new(scene.SceneManager)
	sceneMan^ = scene.MakeSceneManger(renMan, texMan, world)

	engine := Engine {
		sceneManager   = sceneMan,
		renderManager  = renMan,
		textureManager = texMan,
		tileManager    = tileMan,
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
			render.Flush(engine.renderManager, engine.textureManager)
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
	tilemap.Shutdown(engine.tileManager)
}

@(private)
update :: proc(engine: ^Engine) {
	scene.Update(engine.sceneManager)
	player.PlayerInputSystem(engine.world, &engine.frameInput)
	ecs.ProcessTick(engine.world)

	playerView := ecs.View2(engine.world, core.PlayerRef, core.Camera)

	if len(playerView) == 0 {
		// No camera set up yet, skip rendering setup
		return
	}

	camera := playerView[0].c2
	tilemap.MaybeGenerateNewChunks(engine.tileManager, camera.camera, engine.renderManager)
	tilemap.DrawTilemap(engine.tileManager, camera.camera, engine.renderManager)
	render.RenderSprites(engine.world, engine.renderManager, engine.textureManager)
	screenRect := core.GetScreenRect(camera.camera)

	render.DrawRect(engine.renderManager, screenRect, rl.BLUE)

}
