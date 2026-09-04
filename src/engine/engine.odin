package engine

import "base:runtime"
import "src:core"
import "src:ecs"
import "src:event"
import "src:input"
import "src:log"
import "src:neb_utils"
import "src:player"
import "src:render"
import "src:scene"
import "src:texture"
import "src:tilemap"
import "src:ui"
import rl "vendor:raylib"

Engine :: struct {
	queue:          ^event.Queue,
	sceneManager:   ^scene.SceneManager,
	renderManager:  ^render.RenderManager,
	textureManager: ^texture.TextureManager,
	tileManager:    ^tilemap.TileManager,
	world:          ^ecs.World,
	frameInput:     input.State,
	rng:            runtime.Random_Generator,
}

MakeEngine :: proc() -> Engine {
	queue := new(event.Queue)
	queue^ = event.MakeQueue()

	texMan := new(texture.TextureManager)
	texMan^ = texture.MakeTextureManager()

	world := new(ecs.World)
	world^ = ecs.CreateWorld()

	renMan := new(render.RenderManager)
	renMan^ = render.MakeRenderManager()

	tileMan := new(tilemap.TileManager)
	tileMan^ = tilemap.MakeTileManager()

	sceneMan := new(scene.SceneManager)
	sceneMan^ = scene.MakeSceneManger(texMan, world, queue)

	rng := neb_utils.InitNewGenerator()

	engine := Engine {
		sceneManager   = sceneMan,
		renderManager  = renMan,
		textureManager = texMan,
		tileManager    = tileMan,
		world          = world,
		queue          = queue,
		rng            = rng,
	}

	return engine
}

Init :: proc(engine: ^Engine) {
	ui.InitMu()
	scene.LoadFirstScene(engine.sceneManager)
}

Run :: proc(engine: ^Engine) {
	shouldBlockInput: bool
	for !rl.WindowShouldClose() {
		core.FullscreenManager()
		processEvents(engine)

		if !scene.ShouldBlockInput(engine.sceneManager) {
			engine.frameInput = input.Poll(core.DefaultKeybinds)
			engineInput(engine)
		}

		update(engine)

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		switch engine.sceneManager.current {
		case .MENU:
		// TODO: add menu scene rendering
		case .GAME:
			playerEntity, playerErr := player.GetPlayer(
				engine.world,
				player.MAIN_PLAYER_REF,
				core.Camera,
			)
			defer ecs.Cleanup(&playerEntity)
			if playerErr {
				// No camera set up yet, skip rendering
				break
			}
			cameraComponent, camErr := ecs.ComponentSetGet(&playerEntity, core.Camera)
			if camErr {
				break
			}
			camera := cast(^core.Camera)cameraComponent
			rl.BeginMode2D(camera.camera)
			render.Flush(engine.renderManager, engine.textureManager)
			rl.EndMode2D()
		}

		scene.DrawTransition(engine.sceneManager)
		rl.DrawText(rl.TextFormat("%d", rl.GetFPS()), 12, 12, 24, rl.BLACK)
		rl.DrawText(rl.TextFormat("%d", rl.GetFPS()), 10, 10, 24, rl.WHITE)
		ui.FrameMu(&engine.frameInput)
		rl.EndDrawing()

		ecs.FrameEnd(engine.world)
	}
}

Shutdown :: proc(engine: ^Engine) {
	inventoryView := ecs.View1(engine.world, core.Inventory)

	for entity in inventoryView {
		delete(entity.c1.slots)
	}

	ecs.EndWorld(engine.world)
	texture.Shutdown(engine.textureManager)
	tilemap.Shutdown(engine.tileManager)
	render.Shutdown(engine.renderManager)
	ui.ShutdownMu()

	free(engine.rng.data)
	delete(engine.queue.items)
	free(engine.queue)
	free(engine.world)
	free(engine.textureManager)
	free(engine.tileManager)
	free(engine.renderManager)
	free(engine.sceneManager)

	free_all(context.temp_allocator)
}

@(private)
engineInput :: proc(engine: ^Engine) {
	ui.InputMu(&engine.frameInput)
	switch engine.sceneManager.current {
	case .MENU:
		if input.MaybeConsumeMouse(&engine.frameInput, .LEFT) {
			free(engine.rng.data)
			engine.rng = neb_utils.InitNewGenerator()
			scene.LoadScene(engine.sceneManager, .GAME)
		}
		if input.MaybeConsumeMouse(&engine.frameInput, .RIGHT) {
			free(engine.rng.data)
			seed := 6283573998654693917
			engine.rng = neb_utils.InitSeededGenerator(u64(seed))
			scene.LoadScene(engine.sceneManager, .GAME)
		}
	case .GAME:
		if rl.IsKeyPressed(.ENTER) {
			scene.LoadScene(engine.sceneManager, .MENU)
		}
	}
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
	tilemap.TilemapClickSystem(engine.tileManager, engine.world, &engine.frameInput, camera.camera)

	if (engine.sceneManager.transition.state == .NONE) {
		tilemap.MaybeGenerateNewChunks(
			engine.tileManager,
			camera.camera,
			engine.renderManager,
			engine.world,
		)
	}

	tilemap.DrawTilemap(engine.tileManager, camera.camera, engine.renderManager, engine.world)
	render.RenderSprites(engine.world, engine.renderManager, engine.textureManager)
	screenRect := core.GetScreenRect(camera.camera)

	if core.DEBUG.drawScreenBounds {
		render.DrawRect(engine.renderManager, screenRect, rl.BLUE)
	}
}

@(private)
processEvents :: proc(engine: ^Engine) {
	for item in engine.queue.items {
		#partial switch variant in item {
		case event.GenerateWorld:
			tilemap.GenerateWorld(engine.tileManager, engine.rng)
		case event.ClearTilemap:
			tilemap.ClearChunks(engine.tileManager)
		case event.GenerateBlocks:
			tilemap.GenerateBlocks(engine.tileManager, engine.world)
		}
	}

	clear(&engine.queue.items)
}
