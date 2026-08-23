package tilemap

import "src:core"
import "src:log"

GradientEntry :: struct {
	start: f32,
	end:   f32,
	tile:  core.TileId,
}

Gradient :: []GradientEntry

@(private)
getTileFromGradient :: proc(value: f32, gradient: ^Gradient) -> core.TileId {
	if gradient == nil {
		log.Warn("Tried getting tile from undefined gradient!")
		return .NONE
	}

	if value == 1 {
		return gradient[len(gradient) - 1].tile
	}

	for entry in gradient {
		if value >= entry.start && value < entry.end {
			return entry.tile
		}
	}

	log.Warn("Could not find proper tile inside gradient! %+v", gradient^)
	return .NONE
}

@(private)
GrasslandsGradient: Gradient : {
	{start = 0, end = 0.05, tile = .WATER},
	{start = 0.05, end = 0.15, tile = .SAND},
	{start = 0.15, end = 0.50, tile = .DIRT},
	{start = 0.50, end = 1, tile = .GRASS},
}

@(private)
WaterGradient: Gradient : {
	{start = 0, end = 0.98, tile = .WATER},
	{start = 0.98, end = 1, tile = .SAND},
}

@(private)
DesertGradient: Gradient : {
	{start = 0, end = 0.1, tile = .WATER},
	{start = 0.1, end = 0.95, tile = .SAND},
	{start = 0.95, end = 1, tile = .DIRT},
}
