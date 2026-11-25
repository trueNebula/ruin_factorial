package ecs

import "src:repository"

System :: proc(world: ^World)
SystemWithRepo :: proc(world: ^World, repo: ^repository.Repository)

RegisterSetupSystem :: proc(
	world: ^World,
	system: proc(world: ^World, repo: ^repository.Repository),
) {
	append(&world.setup, system)
}

RegisterTickSystem :: proc(world: ^World, system: proc(world: ^World)) {
	append(&world.tick, system)
}

ProcessSetup :: proc(world: ^World, repo: ^repository.Repository) {
	for system in world.setup {
		system(world, repo)
	}
	clear(&world.setup)
}

ProcessTick :: proc(world: ^World) {
	for system in world.tick {
		system(world)
	}
}
