package tilemap

import "src:core"
import rl "vendor:raylib"

Tile :: struct {
	texture: core.Texture,
	rect:    rl.Rectangle,
	anchor:  core.Anchor,
}

TileRepo :: map[core.TileId]Tile

Layer :: [core.ChunkSize]core.TileId

Chunk :: struct {
	x, y:    int,
	base:    Layer,
	overlay: Layer,
	objects: Layer,
}

CreateRepo :: proc() -> TileRepo {
	tileRepo := make(TileRepo)
	tileRepo[.DIRT] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 16, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	return tileRepo
}

MakeTestChunk :: proc() -> Chunk {
	baseLayer: Layer = [core.ChunkSize]core.TileId{}

	for &tile in baseLayer {
		tile = .DIRT
	}

	return {x = 0, y = 0, base = baseLayer}
}

RenderChunk :: proc(chunk: ^Chunk, camera: rl.Camera2D) {
	if chunk == nil {
		return
	}

	padding := 3 // tiles in each direction
	boundingBox := GetChunkBoundingBox(chunk)
	paddedBoundingBox := PadChunkBoundingBox(boundingBox, padding)

	screenRect := rl.Rectangle{}
	screenRect.width = f32(rl.GetScreenWidth()) / camera.zoom
	screenRect.height = f32(rl.GetScreenHeight()) / camera.zoom
	screenRect.x = camera.target.x - (screenRect.width / 2)
	screenRect.y = camera.target.y - (screenRect.height / 2)

	if !rl.CheckCollisionRecs(paddedBoundingBox, screenRect) {
		return
	}

	for tile in chunk.base {
		DrawTile(tile)
	}
}

DrawTile :: proc(tile: core.TileId) {

}
