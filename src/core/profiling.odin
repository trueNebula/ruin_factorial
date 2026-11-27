package core

import "core:prof/spall"
import "core:sync"

PROFILING :: #config(PROFILING, false)

when PROFILING {
	@(private)
	ctx: spall.Context
	@(private)
	buf: spall.Buffer
	@(private)
	backing: []u8

	@(deferred_none = end)
	Scope :: proc(name: string, loc := #caller_location) {
		spall._buffer_begin(&ctx, &buf, name, "", loc)
	}

	@(private)
	end :: proc() {
		spall._buffer_end(&ctx, &buf)
	}

	InitProfiler() :: proc() {
		ctx = spall.context_create("ruin_factorial.spall")
		backing = make([]u8, spall.BUFFER_DEFAULT_SIZE)
		buf = spall.buffer_create(backing, u32(sync.current_thread_id()))
	}

	ShutdownProfiler :: proc() {
		spall.buffer_destroy(&ctx, &buf)
		spall.context_destroy(&ctx)
		delete(backing)
	}
} else {
	@(deferred_none = end)
	Scope :: proc(name: string = "", loc := #caller_location) {}

	@(private)
	end :: proc() {}

	InitProfiler :: proc() {}
	ShutdownProfiler :: proc() {}
}
