package engine

import ecs "src:ecs"

Engine :: struct {
	sceneManager:   SceneManager,
	textureManager: TextureManager,
	world:          ecs.World,
}

MakeEngine :: proc() -> Engine {
	sceneMan := MakeSceneManger()
	texMan := MakeTextureManager()
	world := ecs.CreateWorld()
	engine := Engine {
		sceneManager   = sceneMan,
		textureManager = texMan,
		world          = world,
	}
	loadMenuScene(&engine)
	return engine
}
