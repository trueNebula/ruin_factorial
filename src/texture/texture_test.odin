package texture

import "core:testing"
import "src:core"
import rl "vendor:raylib"

@(test)
testLoadTexture :: proc(t: ^testing.T) {
	rl.SetConfigFlags({.WINDOW_HIDDEN})
	rl.InitWindow(1, 1, "Test Window")
	{
		texManager := MakeTextureManager()

		id := core.Texture.TEST
		path := "assets/image/test.png"

		LoadTexture(&texManager, id, path)
		testing.expect(t, texManager.data[id].path == path)
		testing.expect(t, texManager.data[id].resource != {})
		UnloadTexture(&texManager, id)
	}
	rl.CloseWindow()
}
