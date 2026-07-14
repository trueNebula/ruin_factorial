package managers

import "core:testing"
import rl "vendor:raylib"

@(test)
testLoadTexture :: proc(t: ^testing.T) {
	rl.SetConfigFlags({.WINDOW_HIDDEN})
	rl.InitWindow(1, 1, "Test Window")
	{
		texManager := CreateTextureManager()

		id := Texture.TEST
		path := "assets/image/test.png"

		LoadTexture(&texManager, id, path)
		testing.expect(t, texManager.data[id].path == path)
		testing.expect(t, texManager.data[id].resource != {})
		UnloadTexture(&texManager, id)
	}
	rl.CloseWindow()
}
