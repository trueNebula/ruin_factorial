package neb_utils

import "core:math"
import "core:testing"

@(private)
seed: u64 = 123456

@(test)
testRandomRange :: proc(t: ^testing.T) {
	generator := InitSeededGenerator(seed)
	expected: f32 = 75.686
	value := RandomRange(1, 100, generator)
	err: f32 = 0.001
	isCorrect := math.abs(value - expected) < err
	testing.expect(t, isCorrect)
}

@(test)
testRandomPick :: proc(t: ^testing.T) {
	generator := InitSeededGenerator(seed)
	list: []int = {1, 2, 3, 4, 5, 6, 7, 8}
	value := RandomPick(list[:], generator)
	testing.expect(t, value == 8)
}

@(test)
testPercentChancee :: proc(t: ^testing.T) {
	generator := InitSeededGenerator(seed)
	value := PercentChance(25.5, generator)
	testing.expect(t, value == false)
}
