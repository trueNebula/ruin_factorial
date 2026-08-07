package logger

import "core:testing"

@(test)
testLog :: proc(t: ^testing.T) {
	Init()
	Print("This is a print statement")
	Debug("This is a debug statement")
	Warn("This is a warning")
	Err("This is an error that doesn't panic", panic = false)
	Shutdown()
}
