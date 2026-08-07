package ecs

import "src:texture"

System :: proc(world: ^World)
RenderSystem :: proc(world: ^World, texMan: ^texture.TextureManager)

RegisterSetupSystem :: proc(world: ^World, system: proc(world: ^World)) {
	append(&world.setup, system)
}

RegisterTickSystem :: proc(world: ^World, system: proc(world: ^World)) {
	append(&world.tick, system)
}

RegisterRenderSystem :: proc(world: ^World, system: RenderSystem) {
	append(&world.render, system)
}

ProcessSetup :: proc(world: ^World) {
	for system in world.setup {
		system(world)
	}
}

ProcessTick :: proc(world: ^World) {
	for system in world.tick {
		system(world)
	}
}

ProcessRender :: proc(world: ^World, texMan: ^texture.TextureManager) {
	for system in world.render {
		system(world, texMan)
	}
}
