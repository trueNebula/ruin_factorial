package managers

import "core:fmt"
import u "src:game_utils"
import rl "vendor:raylib"

Texture :: enum {
	UNKNOWN,
	TEST,
	PLAYER,
	TILE,
	ITEM,
	BLOCK,
}

TextureData :: struct {
	path:     u.path,
	resource: rl.Texture2D,
}

TextureManager :: struct {
	data: map[Texture]TextureData,
}

CreateTextureManager :: proc() -> TextureManager {
	manager := TextureManager {
		data = make(map[Texture]TextureData),
	}
	return manager
}

LoadTexture :: proc(manager: ^TextureManager, id: Texture, path: u.path) -> (err: bool) {
	if texData, ok := manager.data[id]; ok {
		fmt.println(
			"Texture with id %s is already loaded! Loaded path: %s, provided path: %s. Overwriting!",
			id,
			texData.path,
			path,
		)
	}

	rlTex := rl.LoadTexture(rl.TextFormat("%s", path))

	if rlTex == {} {
		fmt.println("Tried loading texture at path %s, not found!", path)
		return true
	}

	manager.data[id] = TextureData {
		path     = path,
		resource = rlTex,
	}

	return false
}

UnloadTexture :: proc(manager: ^TextureManager, id: Texture) -> (err: bool) {
	texData, ok := manager.data[id]

	if !ok {
		fmt.print("Tried unloading texture with id %s that was not loaded!", id)
		return true
	}

	rl.UnloadTexture(manager.data[id].resource)
	delete_key(&manager.data, id)
	return false
}
