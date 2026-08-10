package tilemap

import "core:strconv"
import "core:strings"
import "src:core"
import "src:log"
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

Coords2Hash :: proc(x, y: int) -> string {
	xBuf: [32]u8
	yBuf: [32]u8
	xStr := strconv.write_int(
		xBuf[:],
		i64(x),
		/*base=*/
		10,
	)
	yStr := strconv.write_int(
		yBuf[:],
		i64(y),
		/*base=*/
		10,
	)

	return strings.concatenate({xStr, ";", yStr})
}

Hash2Coords :: proc(hash: string) -> (xCoord, yCoord: int) {
	tokens := strings.split(hash, ";", context.temp_allocator)
	x, xOk := strconv.parse_int(tokens[0], 10)
	y, yOk := strconv.parse_int(tokens[1], 10)

	if (!xOk) {
		log.Warn(
			"Could not parse coordinate from hash %v! Defaulting to value 0 for x.",
			tokens[0],
		)
		x = 0
	}

	if (!yOk) {
		log.Warn(
			"Could not parse coordinate from hash %v! Defaulting to value 0 for y.",
			tokens[1],
		)
		y = 0
	}

	return x, y
}

GetChunkAtPos :: proc(tileMan: ^TileManager, pos: rl.Vector2) -> (chunk: ^Chunk, idx: int) {
	return nil, -1
}
