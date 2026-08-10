package tilemap

import "src:core"
import rl "vendor:raylib"

Chunk2World :: proc(chunk: ^Chunk) -> rl.Vector2 {
	return {
		f32(chunk.x) * core.ChunkLenght * core.TileSize,
		f32(chunk.y) * core.ChunkLenght * core.TileSize,
	}
}

GetChunkBoundingBox :: proc(chunk: ^Chunk) -> rl.Rectangle {
	coords := Chunk2World(chunk)
	return {
		x = coords.x,
		y = coords.y,
		width = core.ChunkLenght * core.TileSize,
		height = core.ChunkLenght * core.TileSize,
	}
}

PadChunkBoundingBox :: proc(rect: rl.Rectangle, tileCnt: int) -> rl.Rectangle {
	growSize := f32(tileCnt) * core.TileSize
	return {
		x = rect.x - growSize,
		y = rect.y - growSize,
		width = rect.width + 2 * growSize,
		height = rect.height + 2 * growSize,
	}
}
