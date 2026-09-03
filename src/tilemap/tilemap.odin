package tilemap

import "core:math"
import "src:core"
import "src:log"
import "src:render"
import rl "vendor:raylib"

Tile :: struct {
	texture: core.Texture,
	rect:    rl.Rectangle,
	anchor:  core.Anchor,
	useMask: bool,
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
	seeds:  Seeds,
}

CreateRepo :: proc() -> TileRepo {
	tileRepo := make(TileRepo)
	tileRepo[.DIRT] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 256, y = 32, width = 256, height = 256},
		anchor = .TOP_LEFT,
		useMask = true,
	}

	tileRepo[.SAND] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 512, y = 32, width = 256, height = 256},
		anchor = .TOP_LEFT,
		useMask = true,
	}

	tileRepo[.GRASS] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 0, y = 32, width = 256, height = 256},
		anchor = .TOP_LEFT,
		useMask = true,
	}

	tileRepo[.WATER] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 0, y = 16, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.GRAVEL] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 64, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.STONE] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 80, y = 0, width = 16, height = 16},
		anchor = .TOP_LEFT,
	}

	tileRepo[.SNOW] = Tile {
		texture = .TILE,
		rect = rl.Rectangle{x = 96, y = 0, width = 16, height = 16},
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
		seeds  = CreateSeeds(),
	}

	return tileMan

}

DrawTilemap :: proc(tileMan: ^TileManager, camera: rl.Camera2D, renMan: ^render.RenderManager) {
	for _, &chunk in tileMan.chunks {
		drawChunk(tileMan, &chunk, camera, renMan)
	}
}

MaybeGenerateNewChunks :: proc(
	tileMan: ^TileManager,
	camera: rl.Camera2D,
	renMan: ^render.RenderManager,
) {
	screenRect := core.GetScreenRect(camera)
	paddedScreenRect := PadChunkBoundingBox(screenRect, 1 * core.ChunkLenght)

	if core.DEBUG.drawChunkGenBounds {
		render.DrawRect(renMan, paddedScreenRect, rl.WHITE)
	}

	cameraCoords := core.GetPos(paddedScreenRect)
	chunkCoords := Screen2Chunk(cameraCoords)
	chunksCoveredHorizontal := math.ceil(
		paddedScreenRect.width / (core.ChunkLenght * core.TileSize),
	)
	chunksCoveredVertical := math.ceil(
		paddedScreenRect.height / (core.ChunkLenght * core.TileSize),
	)

	for y in 0 ..< chunksCoveredVertical {
		for x in 0 ..< chunksCoveredHorizontal {
			currChunkCoords := chunkCoords + rl.Vector2{x, y}
			currChunkHash := Coords2Hash(int(currChunkCoords.x), int(currChunkCoords.y))
			if _, ok := tileMan.chunks[currChunkHash]; ok {
				delete(currChunkHash)
				// chunk exists, skip
				continue
			}

			chunk := generateChunk(tileMan, int(currChunkCoords.x), int(currChunkCoords.y))
			tileMan.chunks[currChunkHash] = chunk
		}
	}
}

ClearChunks :: proc(tileMan: ^TileManager) {
	for hash, chunk in tileMan.chunks {
		delete_key(&tileMan.chunks, hash)
		delete(hash)
	}
	clear_map(&tileMan.chunks)
}

Shutdown :: proc(tileMan: ^TileManager) {
	delete(tileMan.repo)
	for hash, chunk in tileMan.chunks {
		delete_key(&tileMan.chunks, hash)
		delete(hash)
	}

	delete(tileMan.chunks)

	for biome in tileMan.biomes {
		delete(biome.gradient)
	}

	delete(tileMan.biomes)
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

	padding := core.DEBUG.largerTilemapRendering ? 3 * core.ChunkLenght : 3 // tiles in each direction
	boundingBox := GetChunkBoundingBox(chunk)
	screenRect := core.GetScreenRect(camera)
	paddedScreenRect := PadChunkBoundingBox(screenRect, padding)

	if !rl.CheckCollisionRecs(boundingBox, paddedScreenRect) {
		return
	}

	if core.DEBUG.drawChunkBounds {
		render.DrawRect(renMan, boundingBox, rl.GRAY)
	}

	for tile, idx in chunk.base {
		tileX := chunk.x * core.ChunkLenght + idx % core.ChunkLenght
		tileY := chunk.y * core.ChunkLenght + idx / core.ChunkLenght

		fromX := int(math.floor(paddedScreenRect.x / core.TileSize))
		fromY := int(math.floor(paddedScreenRect.y / core.TileSize))
		toX := int(math.ceil((paddedScreenRect.x + paddedScreenRect.width) / core.TileSize))
		toY := int(math.ceil((paddedScreenRect.y + paddedScreenRect.height) / core.TileSize))

		if tileX < fromX || tileX > toX || tileY < fromY || tileY > toY {
			continue
		}

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
	dest := rl.Vector2 {
		f32(chunk.x * core.ChunkLenght + idx % core.ChunkLenght) * core.TileSize,
		f32(chunk.y * core.ChunkLenght + idx / core.ChunkLenght) * core.TileSize,
	}

	rect: rl.Rectangle

	if tileData.useMask {
		rect = {
			x      = tileData.rect.x + f32(i32(dest.x) %% i32(tileData.rect.width)),
			y      = tileData.rect.y + f32(i32(dest.y) %% i32(tileData.rect.height)),
			width  = core.TileSize,
			height = core.TileSize,
		}
	} else {
		rect = tileData.rect
	}
	inset :: f32(0.01)
	rect.x += inset
	rect.y += inset
	rect.width -= inset * 2
	rect.height -= inset * 2


	render.DrawTile(renMan, tex, rect, dest)
}
