package neb_utils

import "base:runtime"
import "core:math/rand"

@(private)
generatorState: rand.Default_Random_State

InitSeededGenerator :: proc(seed: u64) -> runtime.Random_Generator {
	generatorState = rand.create_u64(seed)
	return runtime.default_random_generator(&generatorState)
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

RandomPick :: proc(
	list: []$T,
	generator: runtime.Random_Generator = context.random_generator,
) -> T {
	return rand.choice(list[:], generator)
}

PercentChance :: proc(
	chance: f32,
	generator: runtime.Random_Generator = context.random_generator,
) -> bool {
	return rand.float32(generator) * 100 <= chance
}
