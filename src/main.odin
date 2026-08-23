package main

import "core:fmt"
import "core:mem"
import "src:core"
import "src:engine"
import "src:log"
import rl "vendor:raylib"

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	rl.SetConfigFlags({.WINDOW_RESIZABLE})
	rl.SetExitKey(.KEY_NULL)
	rl.InitWindow(core.WindowDefaults.width, core.WindowDefaults.height, core.WindowDefaults.title)
	rl.SetWindowMinSize(core.WindowDefaults.minWidth, core.WindowDefaults.minHeight)
	defer rl.CloseWindow()

	log.Init()
	Engine := engine.MakeEngine()
	engine.Run(&Engine)
	engine.Shutdown(&Engine)

	total := 0
	for _, entry in track.allocation_map {
		total += entry.size
	}
	log.Print("Live allocations: %+v bytes across %+v entries", total, len(track.allocation_map))
	for _, entry in track.allocation_map {
		log.Print("%+v - %+v bytes", entry.location, entry.size)
	}
	mem.tracking_allocator_destroy(&track)

	log.Shutdown()
}
