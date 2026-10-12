package texture

import "core:fmt"
import "core:strings"
import "src:core"
import rl "vendor:raylib"

DEFAULT_FONT_SIZE :: 64

TextureData :: struct {
	path:     core.Path,
	resource: rl.Texture2D,
}

FontData :: struct {
	path:     core.Path,
	resource: rl.Font,
}

TextureManager :: struct {
	data:  map[core.Texture]TextureData,
	fonts: map[core.Font]FontData,
}

MakeTextureManager :: proc() -> TextureManager {
	manager := TextureManager {
		data = make(map[core.Texture]TextureData),
	}
	return manager
}

LoadTexture :: proc(
	texMan: ^TextureManager,
	id: core.Texture,
	partialPath: core.Path,
) -> (
	err: bool,
) {
	path := strings.concatenate({"assets/image/", partialPath})

	if id in texMan.data {
		texData := texMan.data[id]
		fmt.println(
			"Texture with id %s is already loaded! Loaded path: %s, provided path: %s. Overwriting!",
			id,
			texData.path,
			path,
		)
	}

	rlTex := rl.LoadTexture(rl.TextFormat("%s", path))

	if rlTex.id == 0 {
		fmt.println("Tried loading texture at path %s, not found!", path)
		return true
	}

	texMan.data[id] = TextureData {
		path     = path,
		resource = rlTex,
	}

	return false
}

UnloadTexture :: proc(texMan: ^TextureManager, id: core.Texture) -> (err: bool) {
	texData, ok := texMan.data[id]

	if !ok {
		fmt.print("Tried unloading texture with id %s that was not loaded!", id)
		return true
	}

	rl.UnloadTexture(texMan.data[id].resource)
	delete(texData.path)
	delete_key(&texMan.data, id)
	return false
}

GetTexture :: proc(texMan: ^TextureManager, id: core.Texture) -> (tex: rl.Texture2D, err: bool) {
	texData, ok := texMan.data[id]

	if !ok {
		fmt.println("Tried getting texture with id %s that was not loaded!", id)
		return {}, true
	}

	return texData.resource, false
}

LoadFont :: proc(texMan: ^TextureManager, id: core.Font, partialPath: core.Path) -> (err: bool) {
	path := strings.concatenate({"assets/fonts/", partialPath})

	if id in texMan.fonts {
		fontData := texMan.fonts[id]
		fmt.println(
			"Font with id %s is already loaded! Loaded path: %s, provided path: %s. Overwriting!",
			id,
			fontData.path,
			path,
		)
	}

	rlFont := rl.LoadFontEx(rl.TextFormat("%s", path), DEFAULT_FONT_SIZE, nil, 0)

	if rlFont.glyphCount == 0 {
		fmt.println("Tried loading font at path %s, not found!", path)
		return true
	}

	texMan.fonts[id] = FontData {
		path     = path,
		resource = rlFont,
	}

	return false
}

UnloadFont :: proc(texMan: ^TextureManager, id: core.Font) -> (err: bool) {
	fontData, ok := texMan.fonts[id]

	if !ok {
		fmt.print("Tried unloading font with id %s that was not loaded!", id)
		return true
	}

	rl.UnloadFont(texMan.fonts[id].resource)
	delete(fontData.path)
	delete_key(&texMan.fonts, id)
	return false
}

GetFont :: proc(texMan: ^TextureManager, id: core.Font) -> (tex: rl.Font, err: bool) {
	fontData, ok := texMan.fonts[id]

	if !ok {
		fmt.println("Tried getting font with id %s that was not loaded!", id)
		return {}, true
	}

	return fontData.resource, false
}

Shutdown :: proc(texMan: ^TextureManager) {
	for id in texMan.data {
		UnloadTexture(texMan, id)
	}
	delete(texMan.data)
}
