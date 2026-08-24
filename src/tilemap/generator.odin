package tilemap

import "core:math/noise"
import "src:core"
import "src:log"
import rl "vendor:raylib"

HEIGHT_MAP: rl.RenderTexture2D
BIOME_MAP: rl.RenderTexture2D
BIOME_WARP: rl.RenderTexture2D
HEIGHT_SEED :: 6283573998654693917
BIOME_SEED :: 6283573998129693917
BIOME_WARP_SEED :: 2283573998129693917

NoiseMapSettings :: struct {
	octaves:    int,
	frequency:  f32,
	amplitude:  f32,
	lacunarity: f32,
	gain:       f32,
}

HEIGHT_MAP_SETTINGS: NoiseMapSettings : {
	octaves = 3,
	frequency = 6 * 1.0 / 1000,
	amplitude = 1.0,
	lacunarity = 2.0,
	gain = 0.55,
}

BIOME_MAP_SETTINGS: NoiseMapSettings : {
	octaves = 2,
	frequency = 0.5 * 1.0 / 1000,
	amplitude = 1.0,
	lacunarity = 4.0,
	gain = 0.70,
}

BIOME_WARP_SETTINGS: NoiseMapSettings : {
	octaves = 2,
	frequency = 12 * 1.0 / 1000,
	amplitude = 1.0,
	lacunarity = 2.25,
	gain = 0.66,
}

WARP_STRENGTH :: 0.1

GenerateWorld :: proc(tileMan: ^TileManager) {
	worldLength: int : 16

	HEIGHT_MAP = rl.LoadRenderTexture(
		i32(core.ChunkLenght * worldLength),
		i32(core.ChunkLenght * worldLength),
	)
	BIOME_MAP = rl.LoadRenderTexture(
		i32(core.ChunkLenght * worldLength),
		i32(core.ChunkLenght * worldLength),
	)
	BIOME_WARP = rl.LoadRenderTexture(
		i32(core.ChunkLenght * worldLength),
		i32(core.ChunkLenght * worldLength),
	)

	for chunkY in -(worldLength / 2) ..= (worldLength / 2) {
		for chunkX in -(worldLength / 2) ..= (worldLength / 2) {
			hash := Coords2Hash(chunkX, chunkY)
			chunk := generateChunk(tileMan, chunkY, chunkX)
			tileMan.chunks[hash] = chunk
		}
	}

	if (core.DEBUG_DRAW_CHUNK_NOISE_MAPS) {
		rl.ExportImage(rl.LoadImageFromTexture(HEIGHT_MAP.texture), "height_map.png")
		rl.ExportImage(rl.LoadImageFromTexture(BIOME_MAP.texture), "biome_map.png")
		rl.ExportImage(rl.LoadImageFromTexture(BIOME_WARP.texture), "warp.png")
	}
}

@(private)
generateChunk :: proc(tileMan: ^TileManager, x, y: int) -> Chunk {
	chunk := Chunk {
		x = x,
		y = y,
	}

	for tileIdx in 0 ..< core.ChunkSize {
		tileX := tileIdx % core.ChunkLenght
		tileY := tileIdx / core.ChunkLenght
		tile := generateTile(tileMan, tileX, tileY, x, y)
		chunk.base[tileIdx] = tile
	}

	// log.Debug("Generated new chunk at position %+v %+v!", x, y)
	return chunk
}

@(private)
generateTile :: proc(tileMan: ^TileManager, x, y: int, cX, cY: int) -> core.TileId {
	coinflip := (x + y) % 2 == 0

	texX := x + cX * core.ChunkLenght
	texY := y + cY * core.ChunkLenght

	heightValue := fbmPixel(core.ToVector(texX, texY), HEIGHT_SEED, HEIGHT_MAP_SETTINGS)
	biomeValue := fbmPixel(core.ToVector(texX, texY), BIOME_SEED, BIOME_MAP_SETTINGS)
	warp := fbmPixel(core.ToVector(texX, texY), BIOME_WARP_SEED, BIOME_WARP_SETTINGS)

	if (core.DEBUG_DRAW_CHUNK_NOISE_MAPS) {
		rl.BeginTextureMode(HEIGHT_MAP)
		hColor := rl.Color {
			u8(heightValue * 255),
			u8(heightValue * 255),
			u8(heightValue * 255),
			255,
		}
		rl.DrawPixel(i32(texX + 4 * core.ChunkLenght), i32(-texY + 4 * core.ChunkLenght), hColor)
		rl.EndTextureMode()

		rl.BeginTextureMode(BIOME_MAP)
		bColor := rl.Color{u8(biomeValue * 255), u8(biomeValue * 255), u8(biomeValue * 255), 255}
		rl.DrawPixel(i32(texX + 4 * core.ChunkLenght), i32(-texY + 4 * core.ChunkLenght), bColor)
		rl.EndTextureMode()

		rl.BeginTextureMode(BIOME_WARP)
		wColor := rl.Color{u8(warp * 255), u8(warp * 255), u8(warp * 255), 255}
		rl.DrawPixel(i32(texX + 4 * core.ChunkLenght), i32(-texY + 4 * core.ChunkLenght), wColor)
		rl.EndTextureMode()
	}

	warpedBiomeValue := biomeValue + (warp - 0.5) * WARP_STRENGTH
	biome := getBiomeFromValue(warpedBiomeValue, &tileMan.biomes)
	tile := getTileFromGradient(heightValue, &biome.gradient)

	return tile
}

@(private)
generateNoisePixel :: proc(seed: i64, coords: rl.Vector2) -> f32 {
	return noise.noise_2d_improve_x(seed, {f64(coords.x), f64(coords.y)})
}

@(private)
fbmPixel :: proc(coords: rl.Vector2, seed: i64, settings: NoiseMapSettings) -> f32 {
	value: f32 = 0.0
	freq := settings.frequency
	amp := settings.amplitude

	for oct in 0 ..< settings.octaves {
		noiseVal := noise.noise_2d_improve_x(seed, {f64(freq * coords.x), f64(freq * coords.y)})
		value += amp * noiseVal
		value = clamp(value, -1, 1)
		freq *= settings.lacunarity
		amp *= settings.gain
	}

	/* -1 <= value <= 1 */
	/* We'll lerp it to be from 0 to 1 */
	return (value + 1) / 2
}
