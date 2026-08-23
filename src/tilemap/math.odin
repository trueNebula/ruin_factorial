package tilemap

import "core:math"
import "core:strconv"
import "core:strings"
import "src:core"
import "src:log"
import "src:tilemap"
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

Screen2World :: proc {
	Screen2WorldVec,
	Screen2WorldFloat,
}

Screen2WorldFloat :: #force_inline proc(pos: f32) -> f32 {
	return f32(int(pos / core.TileSize))
}

Screen2WorldVec :: #force_inline proc(pos: rl.Vector2) -> rl.Vector2 {
	return {f32(int(pos.x / core.TileSize)), f32(int(pos.y / core.TileSize))}
}

World2Chunk :: #force_inline proc(pos: rl.Vector2) -> rl.Vector2 {
	chunkX := int(math.floor(pos.x / core.ChunkLenght))
	chunkY := int(math.floor(pos.y / core.ChunkLenght))

	return {f32(chunkX), f32(chunkY)}
}

World2Tile :: #force_inline proc(pos: rl.Vector2) -> rl.Vector2 {
	chunkX := int(pos.x) % core.ChunkLenght
	chunkY := int(pos.y) % core.ChunkLenght

	if chunkX < 0 do chunkX += core.ChunkLenght
	if chunkY < 0 do chunkY += core.ChunkLenght

	return {f32(chunkX), f32(chunkY)}
}

Screen2Chunk :: #force_inline proc(pos: rl.Vector2) -> rl.Vector2 {
	return World2Chunk(Screen2World(pos))
}

Screen2Tile :: #force_inline proc(pos: rl.Vector2) -> rl.Vector2 {
	return World2Tile(Screen2World(pos))
}

Screen2TileIdx :: #force_inline proc(pos: rl.Vector2) -> int {
	return Tile2Idx(World2Tile(Screen2World(pos)))
}

Tile2Idx :: #force_inline proc(pos: rl.Vector2) -> int {
	return int(pos.x) + int(pos.y) * core.ChunkLenght
}

GetChunkAtScreenPos :: #force_inline proc(tileMan: ^TileManager, pos: rl.Vector2) -> ^Chunk {
	worldPos := Screen2World(pos)
	hash := Coords2Hash(int(worldPos.x), int(worldPos.y))
	if chunk, ok := &tileMan.chunks[hash]; ok {
		return chunk
	}

	log.Warn("Tried getting unloaded chunk at screen pos %v!", pos)

	return nil
}

GetChunkAtWorldPos :: #force_inline proc(tileMan: ^TileManager, pos: rl.Vector2) -> ^Chunk {
	hash := Coords2Hash(int(pos.x), int(pos.y))
	if chunk, ok := &tileMan.chunks[hash]; ok {
		return chunk
	}

	log.Warn("Tried getting unloaded chunk at world pos %v!", pos)

	return nil
}

GetChunkAtPos :: #force_inline proc(tileMan: ^TileManager, pos: rl.Vector2) -> ^Chunk {
	hash := Coords2Hash(int(pos.x), int(pos.y))
	if chunk, ok := &tileMan.chunks[hash]; ok {
		return chunk
	}

	log.Warn("Tried getting chunk at invalid world pos %v!", pos)

	return nil
}

// TODO: make this also take in a layer or return tiles from all layers
GetTileAtWorldPos :: #force_inline proc(tileMan: ^TileManager, pos: rl.Vector2) -> core.TileId {
	chunk := GetChunkAtPos(tileMan, pos)
	idx := Tile2Idx(World2Tile(pos))

	if chunk == nil {
		return .NONE
	}

	return chunk.base[idx]
}

// TODO: make this also take in a layer or return tiles from all layers
GetTileAtScreenPos :: #force_inline proc(tileMan: ^TileManager, pos: rl.Vector2) -> core.TileId {
	worldPos := Screen2World(pos)
	chunk := GetChunkAtPos(tileMan, worldPos)

	if chunk == nil {
		return .NONE
	}

	idx := Tile2Idx(World2Tile(worldPos))
	return chunk.base[idx]
}
