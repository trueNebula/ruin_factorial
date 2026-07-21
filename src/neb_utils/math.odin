package neb_utils

import "core:math/linalg"
import rl "vendor:raylib"

ColorLerp :: proc(a: rl.Color, b: rl.Color, t: f32) -> rl.Color {
	src := rl.ColorNormalize(a)
	dst := rl.ColorNormalize(b)
	return rl.ColorFromNormalized(linalg.lerp(src, dst, t))
}

OpacityLerp :: proc(a: u8, b: u8, t: f32) -> u8 {
	floatA := f32(a)
	floatB := f32(b)
	return u8((1 - t) * floatA + t * floatB)
}
