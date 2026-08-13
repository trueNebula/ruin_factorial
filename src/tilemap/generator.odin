package tilemap

import "core:math/noise"
import "src:core"
import rl "vendor:raylib"

GenerateWorld :: proc(tileMan: ^TileManager) {
	worldLength: int : 5

	for chunkY in -(worldLength / 2) ..= (worldLength / 2) {
		for chunkX in -(worldLength / 2) ..= (worldLength / 2) {
			hash := Coords2Hash(chunkX, chunkY)
			chunk := generateChunk(chunkY, chunkX)
			tileMan.chunks[hash] = chunk
		}
	}
}

@(private)
generateChunk :: proc(x, y: int) -> Chunk {
	chunk := Chunk {
		x = x,
		y = y,
	}

	for tileIdx in 0 ..< core.ChunkSize {
		tileX := tileIdx % core.ChunkLenght
		tileY := tileIdx / core.ChunkLenght
		tile := generateTile(tileX, tileY)
		chunk.base[tileIdx] = tile
	}

	return chunk
}

@(private)
generateTile :: proc(x, y: int) -> core.TileId {
	coinflip := (x + y) % 2 == 0
	return coinflip ? .DIRT : .GRASS
}

@(private)
generateNoisePixel :: proc(seed: i64, coords: rl.Vector2) -> f32 {
	return noise.noise_2d_improve_x(seed, {f64(coords.x), f64(coords.y)})
}

@(private)
fbmPixel :: proc(
	coords: rl.Vector2,
	octaves: i32,
	frequency: f32,
	amplitude: f32,
	lacunarity: f32,
	gain: f32,
	seed: i64,
) -> f32 {
	value: f32 = 0.0
	freq := frequency
	amp := amplitude

	for oct in 0 ..< octaves {
		noiseVal := noise.noise_2d_improve_x(
			seed,
			{f64(frequency * coords.x), f64(frequency * coords.y)},
		)
		value += amplitude * noiseVal
		value = clamp(value, -1, 1)
		freq *= lacunarity
		amp *= gain
	}

	return value
}
