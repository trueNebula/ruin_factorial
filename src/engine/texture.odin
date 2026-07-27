package engine

import "core:fmt"
import "core:strings"
import "src:ecs"
import u "src:game_utils"
import rl "vendor:raylib"

TextureData :: struct {
	path:     u.path,
	resource: rl.Texture2D,
}

TextureManager :: struct {
	data: map[ecs.Texture]TextureData,
}

MakeTextureManager :: proc() -> TextureManager {
	manager := TextureManager {
		data = make(map[ecs.Texture]TextureData),
	}
	return manager
}

LoadTexture :: proc(engine: ^Engine, id: ecs.Texture, partialPath: u.path) -> (err: bool) {
	texMan := engine.textureManager
	path := strings.concatenate({"assets/image/", partialPath})

	if texData, ok := texMan.data[id]; ok {
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

	texMan.data[id] = TextureData {
		path     = path,
		resource = rlTex,
	}

	return false
}

UnloadTexture :: proc(engine: ^Engine, id: ecs.Texture) -> (err: bool) {
	texMan := engine.textureManager
	texData, ok := texMan.data[id]

	if !ok {
		fmt.print("Tried unloading texture with id %s that was not loaded!", id)
		return true
	}

	rl.UnloadTexture(texMan.data[id].resource)
	delete_key(&texMan.data, id)
	return false
}

GetTexture :: proc(engine: ^Engine, id: ecs.Texture) -> (tex: rl.Texture2D, err: bool) {
	texMan := engine.textureManager
	texData, ok := texMan.data[id]

	if !ok {
		fmt.println("Tried getting texture with id %s that was not loaded!", id)
		return {}, true
	}

	return texData.resource, false
}
