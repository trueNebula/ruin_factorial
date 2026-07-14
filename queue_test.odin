package structure

import "core:testing"

@(test)
testQueuePush :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)

	Push(&queue, 2)
	testing.expect(t, Length(&queue) == 1)
	Push(&queue, 5, 4, 6)
	testing.expect(t, Length(&queue) == 4)
}

@(test)
testQueuePop :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)
	Push(&queue, 2, 3, 4)

	testing.expect(t, Length(&queue) == 3)
	testing.expect(t, Pop(&queue) == 2)
	testing.expect(t, Length(&queue) == 2)
}

@(test)
testQueueFront :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)

	Push(&queue, 2, 3, 4)
	testing.expect(t, Front(&queue) == 2)
	testing.expect(t, Length(&queue) == 3)
}

@(test)
testQueueBack :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)

	Push(&queue, 2, 3, 4)
	testing.expect(t, Back(&queue) == 4)
	testing.expect(t, Length(&queue) == 3)
}

@(test)
testQueueIncludes :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)

	Push(&queue, 2, 3, 4)
	testing.expect(t, Includes(&queue, 3) == true)
	testing.expect(t, Includes(&queue, 1) == false)
}

@(test)
testQueueEmpty :: proc(t: ^testing.T) {
	queue := MakeQueue(int)
	defer Delete(&queue)

	testing.expect(t, Empty(&queue) == true)
	Push(&queue, 2, 3, 4)
	testing.expect(t, Empty(&queue) == false)
}
