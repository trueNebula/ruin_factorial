package tilemap

import "core:testing"

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
