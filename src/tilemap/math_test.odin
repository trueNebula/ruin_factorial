package tilemap

import "core:log"
import "core:testing"
import rl "vendor:raylib"

@(test)
testCoords2Hash :: proc(t: ^testing.T) {
	x := -2
	y := 10
	testing.expect(t, Coords2Hash(x, y) == "-2;10")
}

@(test)
testHash2Coords :: proc(t: ^testing.T) {
	hash := "-2;10"
	x, y := Hash2Coords(hash)
	testing.expect(t, x == -2)
	testing.expect(t, y == 10)
}

@(test)
testWorld2Chunk :: proc(t: ^testing.T) {
	easyPos := rl.Vector2{12, 70}
	testing.expect(t, World2Chunk(easyPos) == {0, 1})
	worldPos := rl.Vector2{654, -860}
	testing.expect(t, World2Chunk(worldPos) == {10, -13})
}

@(test)
testWorld2Tile :: proc(t: ^testing.T) {
	easyPos := rl.Vector2{12, 70}
	testing.expect(t, World2Tile(easyPos) == {12, 6})
	worldPos := rl.Vector2{654, -860}
	testing.expect(t, World2Tile(worldPos) == {14, 36})
}

@(test)
testScreen2Chunk :: proc(t: ^testing.T) {
	easyPos := rl.Vector2{12, 70}
	testing.expect(t, Screen2Chunk(easyPos) == {0, 0})
	worldPos := rl.Vector2{654, -1242}
	testing.expect(t, Screen2Chunk(worldPos) == {0, -1})
}

@(test)
testScreen2Tile :: proc(t: ^testing.T) {
	easyPos := rl.Vector2{12, 70}
	testing.expect(t, Screen2Tile(easyPos) == {0, 4})
	worldPos := rl.Vector2{654, -1242}
	testing.expect(t, Screen2Tile(worldPos) == {40, 51})
}
