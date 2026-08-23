package tilemap

import "core:slice"
import "src:core"

Biome :: struct {
	id:       core.BiomeId,
	start:    f32,
	end:      f32,
	gradient: Gradient,
}

BiomeList :: [dynamic]Biome

CreateBiomes :: proc() -> BiomeList {
	list: BiomeList = make(BiomeList)

	append(&list, Biome{id = .WATER, start = 0, end = 0.05, gradient = slice.clone(WaterGradient)})
	append(
		&list,
		Biome{id = .DESERT, start = 0.05, end = 0.55, gradient = slice.clone(DesertGradient)},
	)
	append(
		&list,
		Biome{id = .GRASSLANDS, start = 0.55, end = 1, gradient = slice.clone(GrasslandsGradient)},
	)

	return list
}

@(private)
getBiomeFromValue :: proc(value: f32, biomes: ^BiomeList) -> ^Biome {
	if value < 0 {
		return &biomes[0]
	}

	for &biome in biomes {
		if value >= biome.start && value <= biome.end {
			return &biome
		}
	}
	return &biomes[len(biomes) - 1]
}
