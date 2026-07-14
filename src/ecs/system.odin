package ecs

System :: proc(world: ^World)

RegisterSetupSystem :: proc(world: ^World, system: proc(world: ^World)) {
	append(&world.setup, system)
}

RegisterTickSystem :: proc(world: ^World, system: proc(world: ^World)) {
	append(&world.tick, system)
}

RegisterRenderSystem :: proc(world: ^World, system: proc(world: ^World)) {
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

ProcessRender :: proc(world: ^World) {
	for system in world.render {
		system(world)
	}
}
