package engine

import ecs "src:ecs"
import u "src:game_utils"
import "src:scene"
import "src:texture"
import rl "vendor:raylib"

Engine :: struct {
	sceneManager:   scene.SceneManager,
	textureManager: texture.TextureManager,
	world:          ecs.World,
}

MakeEngine :: proc() -> Engine {
	texMan := texture.MakeTextureManager()
	world := ecs.CreateWorld()
	sceneMan := scene.MakeSceneManger(&texMan, &world)
	engine := Engine {
		sceneManager   = sceneMan,
		textureManager = texMan,
		world          = world,
	}
	return engine
}

Run :: proc(engine: ^Engine) {
	for !rl.WindowShouldClose() {
		u.fullscreenManager()


		scene.Input(&engine.sceneManager)

		update(engine)

		rl.BeginDrawing()
		scene.DrawTransition(&engine.sceneManager)
		rl.EndDrawing()
	}
}

@(private)
update :: proc(engine: ^Engine) {
	scene.Update(&engine.sceneManager)
}
