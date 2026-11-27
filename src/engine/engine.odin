package engine

import "base:runtime"
import "core:fmt"
import "src:collision"
import "src:core"
import "src:ecs"
import "src:event"
import "src:input"
import "src:log"
import "src:neb_utils"
import "src:physics"
import "src:player"
import "src:render"
import "src:repository"
import "src:scene"
import "src:texture"
import "src:tilemap"
import "src:ui"
import "src:ui/components"
import rl "vendor:raylib"

Engine :: struct {
	queue:          ^event.Queue,
	sceneManager:   ^scene.SceneManager,
	renderManager:  ^render.RenderManager,
	textureManager: ^texture.TextureManager,
	tileManager:    ^tilemap.TileManager,
	uiManager:      ^ui.UiManager,
	repo:           ^repository.Repository,
	world:          ^ecs.World,
	frameInput:     input.State,
	rng:            runtime.Random_Generator,

	/* DEBUG */
	selectedEntity: u32,
}

MakeEngine :: proc() -> Engine {
	queue := new(event.Queue)
	queue^ = event.MakeQueue()

	repo := new(repository.Repository)
	repo^ = repository.MakeRepository()

	texMan := new(texture.TextureManager)
	texMan^ = texture.MakeTextureManager()

	world := new(ecs.World)
	world^ = ecs.CreateWorld()

	renMan := new(render.RenderManager)
	renMan^ = render.MakeRenderManager()

	tileMan := new(tilemap.TileManager)
	tileMan^ = tilemap.MakeTileManager(repo)

	uiMan := new(ui.UiManager)
	uiMan^ = ui.MakeUiManager()

	sceneMan := new(scene.SceneManager)
	sceneMan^ = scene.MakeSceneManger(texMan, world, queue, uiMan)


	rng := neb_utils.InitNewGenerator()

	engine := Engine {
		sceneManager   = sceneMan,
		renderManager  = renMan,
		textureManager = texMan,
		tileManager    = tileMan,
		uiManager      = uiMan,
		repo           = repo,
		world          = world,
		queue          = queue,
		rng            = rng,
	}

	return engine
}

Init :: proc(engine: ^Engine) {
	texture.LoadFont(
		engine.textureManager,
		core.Font.MAIN,
		"/PixeloidSans.ttf",
		texture.MAIN_FONT_SPACING,
	)
	texture.LoadFont(
		engine.textureManager,
		core.Font.BOLD,
		"/PixeloidSans-Bold.ttf",
		texture.BOLD_FONT_SPACING,
	)
	texture.LoadFont(
		engine.textureManager,
		core.Font.MONO,
		"/PixeloidMono.ttf",
		texture.MONO_FONT_SPACING,
	)

	ui.InitMu()

	if core.DEBUG_SKIP_MENU {
		resetRng(engine, 6283573998654693917)
		scene.LoadScene(engine.sceneManager, .GAME)
	} else {
		scene.LoadFirstScene(engine.sceneManager)
	}

	repository.InitializeRepo(engine.repo)
}

Run :: proc(engine: ^Engine) {
	shouldBlockInput: bool
	for !rl.WindowShouldClose() {
		@(static) acc: [6]f64
		@(static) frames: int

		core.FullscreenManager()

		camera, camErr := player.GetPlayerComponent(
			engine.world,
			player.MAIN_PLAYER_REF,
			core.Camera,
		)
		t0 := rl.GetTime()
		ui.BeginFrame(engine.uiManager, camErr ? nil : camera.camera)
		t1 := rl.GetTime()
		engine.frameInput = input.Poll(core.DefaultKeybinds)

		if ui.WantsMouse(engine.uiManager) {
			engine.frameInput.mouseHeld = {}
			engine.frameInput.mousePressed = {}
			engine.frameInput.mouseConsumed = {}
		}

		if ui.WantsKeyboard(engine.uiManager) {
			engine.frameInput.actionHeld &= {.INVENTORY}
			engine.frameInput.actionPressed &= {.INVENTORY}
		}

		if ui.AllowsClose(engine.uiManager) {
			if .INVENTORY in engine.frameInput.actionPressed {
				if engine.uiManager.menuOpen do engine.uiManager.menu.ui = .NONE
				else do engine.uiManager.menu.ui = .INVENTORY
				engine.uiManager.menuOpen = !engine.uiManager.menuOpen
			}
		}

		engineInput(engine)

		selectedEntityData: ecs.ComponentSet
		defer ecs.Cleanup(&selectedEntityData)
		if core.DEBUG.showWindow && core.DEBUG_SHOW_ENTITY_DATA {
			DebugHandleClickedEntity(engine, camera.camera)
			if engine.selectedEntity != 0 {
				selectedEntityData = ecs.GetAllForEntity(engine.world, engine.selectedEntity)
				if len(selectedEntityData.data) == 0 do engine.selectedEntity = 0
			}
		}

		// update
		update(engine)
		processEvents(engine)
		t2 := rl.GetTime()
		buildUi(engine)
		t3 := rl.GetTime()
		ui.EndFrame(engine.uiManager, engine.textureManager)
		t4 := rl.GetTime()
		// render
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		if engine.sceneManager.current == .GAME && !camErr {
			rl.BeginMode2D(camera.camera)
			render.Flush(engine.renderManager, engine.textureManager)
			ui.FlushWorld(engine.uiManager, engine.textureManager)
			rl.EndMode2D()
		}

		rl.BeginMode2D(engine.uiManager.camera)
		ui.FlushScreen(engine.uiManager, engine.textureManager)
		t5 := rl.GetTime()
		rl.EndMode2D()

		scene.DrawTransition(engine.sceneManager)
		rl.DrawText(rl.TextFormat("%d", rl.GetFPS()), 12, 12, 24, rl.BLACK)
		rl.DrawText(rl.TextFormat("%d", rl.GetFPS()), 10, 10, 24, rl.WHITE)
		if core.DEBUG.showWindow {
			ui.FrameMu(
				&engine.frameInput,
				camera.camera.target,
				engine.selectedEntity,
				selectedEntityData,
				engine.repo,
			)
		}
		rl.EndDrawing()
		t6 := rl.GetTime()

		ecs.FrameEnd(engine.world)

		acc += {t1 - t0, t2 - t1, t3 - t2, t4 - t3, t5 - t4, t6 - t5}
		frames += 1
		if frames == 300 {
			fmt.printf(
				"BeginFrame %.3f ms | update %.3f ms | build %.3f ms | layout %.3f ms | FlushScreen %.3f ms | EndDrawing %.3f ms\n",
				acc[0] / 300 * 1000,
				acc[1] / 300 * 1000,
				acc[2] / 300 * 1000,
				acc[3] / 300 * 1000,
				acc[4] / 300 * 1000,
				acc[5] / 300 * 1000,
			)
			acc = {}
			frames = 0
		}
	}
}

Shutdown :: proc(engine: ^Engine) {
	ecs.EndWorld(engine.world)
	texture.Shutdown(engine.textureManager)
	tilemap.Shutdown(engine.tileManager)
	render.Shutdown(engine.renderManager)
	ui.ShutdownMu()
	ui.Shutdown(engine.uiManager)
	repository.Shutdown(engine.repo)

	free(engine.rng.data)
	delete(engine.queue.items)
	free(engine.queue)
	free(engine.world)
	free(engine.textureManager)
	free(engine.tileManager)
	free(engine.renderManager)
	free(engine.sceneManager)
	free(engine.uiManager)
	free(engine.repo)

	free_all(context.temp_allocator)
}

@(private)
engineInput :: proc(engine: ^Engine) {
	if rl.IsKeyPressed(.GRAVE) {
		core.DEBUG.showWindow = !core.DEBUG.showWindow
	}

	ui.InputMu(&engine.frameInput)
}

@(private)
update :: proc(engine: ^Engine) {
	scene.Update(engine.sceneManager)
	ecs.ProcessSetup(engine.world, engine.repo)

	#partial switch engine.sceneManager.current {
	case .MENU:
	case .GAME:
		player.PlayerInputSystem(engine.world, &engine.frameInput)
		ecs.ProcessTick(engine.world)
		physics.MovementSystem(engine.world, engine.tileManager)
		player.CameraTransformSystem(engine.world)
		collision.CheckCollisions(engine.world, engine.queue)

		playerView := ecs.View2(engine.world, core.PlayerRef, core.Camera)

		if len(playerView) == 0 {
			// No camera set up yet, skip rendering setup
			return
		}

		camera := playerView[0].c2
		tilemap.TilemapClickSystem(
			engine.tileManager,
			engine.world,
			&engine.frameInput,
			camera.camera,
			engine.repo,
			engine.queue,
		)

		if (engine.sceneManager.transition.state == .NONE) {
			tilemap.MaybeGenerateNewChunks(
				engine.tileManager,
				camera.camera,
				engine.renderManager,
				engine.world,
			)
		}

		tilemap.DrawTilemap(engine.tileManager, camera.camera, engine.renderManager, engine.world)
		render.RenderShadows(
			engine.world,
			engine.renderManager,
			engine.textureManager,
			camera.camera,
		)
		render.RenderSprites(
			engine.world,
			engine.renderManager,
			engine.textureManager,
			engine.uiManager.worldCamera,
		)

		if (core.DEBUG.drawColliders) {
			render.RenderColliders(engine.world, engine.renderManager, camera.camera)
		}

		if core.DEBUG.drawScreenBounds {
			screenRect := core.GetScreenRect(camera.camera)
			render.QueueRect(engine.renderManager, screenRect, rl.BLUE)
		}
	case .NONE:
	case:
		unreachable()
	}
}

@(private)
processEvents :: proc(engine: ^Engine) {
	for eventItem in engine.queue.items {
		#partial switch variant in eventItem {
		case event.GenerateWorld:
			tilemap.GenerateWorld(engine.tileManager, engine.rng)
		case event.ClearTilemap:
			tilemap.ClearChunks(engine.tileManager)
		case event.GenerateBlocks:
			tilemap.GenerateBlocks(engine.tileManager, engine.world)
		case event.Collision:
			collision.RouteCollision(variant, engine.queue)
		case event.Pickup:
			player.TryAddToInventory(engine.world, variant.collector, variant.item)
			ecs.Delete(engine.world, variant.item)
		case event.Interact:
			log.Debug("Interact event: %v", variant)
			engine.uiManager.menu = variant.config
		}
	}

	clear(&engine.queue.items)
}

buildUi :: proc(engine: ^Engine) {
	uiMan := engine.uiManager
	#partial switch engine.sceneManager.current {
	case .MENU:
		buildMenuUi(engine)
	case .GAME:
		buildGameUi(engine)
	case .NONE:
	case:
		unreachable()
	}
}

resetRng :: proc(engine: ^Engine, seed: Maybe(int)) {
	free(engine.rng.data)
	seedVal, ok := seed.?

	if ok {
		engine.rng = neb_utils.InitSeededGenerator(u64(seedVal))
	} else {
		engine.rng = neb_utils.InitNewGenerator()
	}
}
