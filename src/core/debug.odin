package core

DEBUG_DRAW_CHUNK_NOISE_MAPS :: false

@(private = "file")
DEBUG_DRAW_SCREEN_BOUNDS :: false

@(private = "file")
DEBUG_DRAW_CHUNK_BOUNDS :: true

@(private = "file")
DEBUG_DRAW_CHUNK_GEN_BOUNDS :: false

DEBUG_DEFAULT_ZOOM :: 4.0

@(private = "file")
DEBUG_ZOOM :: 0.0

@(private = "file")
DEBUG_LARGER_TILEMAP_RENDERING :: false

DebugOptions :: struct {
	drawChunkNoiseMaps:     bool,
	drawScreenBounds:       bool,
	drawChunkBounds:        bool,
	drawChunkGenBounds:     bool,
	largerTilemapRendering: bool,
	zoom:                   f32,
}

DEBUG := DebugOptions {
	drawChunkNoiseMaps     = DEBUG_DRAW_CHUNK_NOISE_MAPS,
	drawScreenBounds       = DEBUG_DRAW_SCREEN_BOUNDS,
	drawChunkGenBounds     = DEBUG_DRAW_CHUNK_GEN_BOUNDS,
	largerTilemapRendering = DEBUG_LARGER_TILEMAP_RENDERING,
	zoom                   = DEBUG_ZOOM,
}
