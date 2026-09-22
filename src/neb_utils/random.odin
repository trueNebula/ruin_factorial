package neb_utils

import "base:runtime"
import "core:math/rand"
import "core:time"

InitSeededGenerator :: proc(seed: u64) -> runtime.Random_Generator {
	generatorState := new(rand.Default_Random_State)
	generatorState^ = rand.create_u64(seed)
	return runtime.default_random_generator(generatorState)
}

InitNewGenerator :: proc() -> runtime.Random_Generator {
	now := time.now()
	return InitSeededGenerator(u64(now._nsec))
}

RandomRange :: proc(
	min, max: f32,
	generator: runtime.Random_Generator = context.random_generator,
) -> f32 {
	if min >= max {
		return min
	}
	return min + rand.float32(generator) * (max - min)
}

RandomRangeI32 :: proc(
	min, max: i32,
	generator: runtime.Random_Generator = context.random_generator,
) -> i32 {
	if min >= max {
		return min
	}
	return min + rand.int31_max(max - min, generator)
}

RandomPick :: proc(
	list: []$T,
	generator: runtime.Random_Generator = context.random_generator,
) -> T {
	return rand.choice(list[:], generator)
}

RandomRangeGaussian :: proc(
	min: f32,
	max: f32,
	generator: runtime.Random_Generator = context.random_generator,
) -> f32 {
	mean := (max + min) / 2
	stddev := (max - min) / 6
	return clamp(rand.float32_normal(mean, stddev, generator), min, max)
}

PercentChance :: proc(
	chance: f32,
	generator: runtime.Random_Generator = context.random_generator,
) -> bool {
	return rand.float32(generator) * 100 <= chance
}

PercentChanceSeeded :: proc(chance: f32, seed: u64) -> bool {
	return chance > hashToF32(seed) * 100
}

XInYChance :: proc(
	chance: f32,
	generator: runtime.Random_Generator = context.random_generator,
) -> bool {
	return rand.float32(generator) <= chance
}

RandomI64 :: proc(generator: runtime.Random_Generator = context.random_generator) -> i64 {
	return rand.int63(generator)
}

@(private)
hashToF32 :: proc(h: u64) -> f32 {
	return f32(h >> 40) / f32(1 << 24)
}
