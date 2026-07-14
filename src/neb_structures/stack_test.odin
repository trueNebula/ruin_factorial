package structure

import "core:testing"

@(test)
testStackPush :: proc(t: ^testing.T) {
	stack := MakeStack(int)
	defer Delete(&stack)

	Push(&stack, 2)
	testing.expect(t, Length(&stack) == 1)
	Push(&stack, 5, 4, 6)
	testing.expect(t, Length(&stack) == 4)
}

@(test)
testStackPop :: proc(t: ^testing.T) {
	stack := MakeStack(int)
	defer Delete(&stack)
	Push(&stack, 2, 3, 4)

	testing.expect(t, Length(&stack) == 3)
	testing.expect(t, Pop(&stack) == 4)
	testing.expect(t, Length(&stack) == 2)
}

@(test)
testStackPeek :: proc(t: ^testing.T) {
	stack := MakeStack(int)
	defer Delete(&stack)

	Push(&stack, 2, 3, 4)
	testing.expect(t, Peek(&stack) == 4)
	testing.expect(t, Length(&stack) == 3)
}

@(test)
testStackIncludes :: proc(t: ^testing.T) {
	stack := MakeStack(int)
	defer Delete(&stack)

	Push(&stack, 2, 3, 4)
	testing.expect(t, Includes(&stack, 3) == true)
	testing.expect(t, Includes(&stack, 1) == false)
}

@(test)
testStackEmpty :: proc(t: ^testing.T) {
	stack := MakeStack(int)
	defer Delete(&stack)

	testing.expect(t, Empty(&stack) == true)
	Push(&stack, 2, 3, 4)
	testing.expect(t, Empty(&stack) == false)
}
