package engine

import "src:core"
import "src:ecs"
import u "src:game_utils"
import "src:scene"
import "src:texture"
import rl "vendor:raylib"

Engine :: struct {
	sceneManager:   ^scene.SceneManager,
	textureManager: ^texture.TextureManager,
	world:          ^ecs.World,
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
		u.fullscreenManager()

		scene.Input(engine.sceneManager)

		update(engine)

		rl.BeginDrawing()

		switch engine.sceneManager.current {
		case .MENU:
		// TODO: add menu scene rendering
		case .GAME:
			view := ecs.View2(engine.world, core.PlayerRef, core.Camera)
			if len(view) == 0 {
				// No camera set up yet, skip rendering
				break
			}
			camera := view[0].c2
			rl.BeginMode2D(camera.camera)
			ecs.ProcessRender(engine.world, engine.textureManager)
			rl.EndMode2D()
		}

		scene.DrawTransition(engine.sceneManager)
		rl.EndDrawing()

		ecs.FrameEnd(engine.world)
	}
}

@(private)
update :: proc(engine: ^Engine) {
	scene.Update(engine.sceneManager)
}
