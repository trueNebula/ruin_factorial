package tilemap

import "src:core"
import "src:log"
import "src:render"
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

ChunkMap :: map[string]Chunk

TileManager :: struct {
	repo:   TileRepo,
	chunks: ChunkMap,
	biomes: BiomeList,
}

CreateRepo :: proc() -> TileRepo {
	tileRepo := make(TileRepo)
	tileRepo[.DIRT] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 16, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.SAND] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 32, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.GRASS] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 48, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.WATER] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 0, y = 16, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	return tileRepo
}

MakeTileManager :: proc() -> TileManager {
	chunkMap := make(ChunkMap)
	tileMan := TileManager {
		repo   = CreateRepo(),
		chunks = chunkMap,
		biomes = CreateBiomes(),
	}

	GenerateWorld(&tileMan)

	return tileMan

}

DrawTilemap :: proc(tileMan: ^TileManager, camera: rl.Camera2D, renMan: ^render.RenderManager) {
	for _, &chunk in tileMan.chunks {
		drawChunk(tileMan, &chunk, camera, renMan)
	}
}

@(private)
makeTestChunk :: proc() -> Chunk {
	baseLayer: Layer = [core.ChunkSize]core.TileId{}

	for idx in 0 ..< core.ChunkSize {
		baseLayer[idx] = .DIRT
	}

	return {x = 0, y = 0, base = baseLayer}
}

@(private)
drawChunk :: proc(
	tileMan: ^TileManager,
	chunk: ^Chunk,
	camera: rl.Camera2D,
	renMan: ^render.RenderManager,
) {
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

	for tile, idx in chunk.base {
		drawTile(tileMan, tile, idx, chunk, renMan)
	}
}

@(private)
drawTile :: proc(
	tileMan: ^TileManager,
	tile: core.TileId,
	idx: int,
	chunk: ^Chunk,
	renMan: ^render.RenderManager,
) {
	tileData, ok := tileMan.repo[tile]
	if (!ok) {
		log.Warn("Tried to access tile with id %v in tile repo, tile id doesnt exist!", tile)
		return
	}

	tex := tileData.texture
	rect := tileData.rect
	inset :: f32(0.01)
	rect.x += inset
	rect.y += inset
	rect.width -= inset * 2
	rect.height -= inset * 2
	dest := rl.Vector2 {
		f32(chunk.x * core.ChunkLenght + idx % core.ChunkLenght) * core.TileSize,
		f32(chunk.y * core.ChunkLenght + idx / core.ChunkLenght) * core.TileSize,
	}

	render.DrawTile(renMan, tex, rect, dest)
}
