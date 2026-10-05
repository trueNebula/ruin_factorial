package render

import "src:core"
import "src:log"
import "src:texture"
import rl "vendor:raylib"

DrawCommand :: struct {
	texture: core.Texture,
	src:     rl.Rectangle,
	dest:    rl.Vector2,
	sortY:   bool,
	zoom:    f32,
	tint:    rl.Color,
}

ShapeDrawCommand :: struct {
	shape:  core.Shape,
	rect:   rl.Rectangle,
	radius: f32,
	dest:   rl.Vector2,
	color:  rl.Color,
}

RenderManager :: struct {
	tile:     [dynamic]DrawCommand,
	shadow:   [dynamic]DrawCommand,
	object:   [dynamic]DrawCommand,
	debug:    [dynamic]ShapeDrawCommand,
	uiSprite: [dynamic]DrawCommand,
}

MakeRenderManager :: proc() -> RenderManager {
	tile := make([dynamic]DrawCommand)
	shadow := make([dynamic]DrawCommand)
	object := make([dynamic]DrawCommand)
	debug := make([dynamic]ShapeDrawCommand)
	uiSprite := make([dynamic]DrawCommand)

	return {tile = tile, shadow = shadow, object = object, debug = debug, uiSprite = uiSprite}
}

Flush :: proc(renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	for cmd in renMan.tile {
		texData, err := texture.GetTexture(texMan, cmd.texture)

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", cmd.texture, panic = false)
			continue
		}

		destRect := core.MakeRect(cmd.dest, {core.TileSize, core.TileSize} * cmd.zoom)
		rl.DrawTexturePro(
			texData,
			cmd.src,
			destRect,
			/*origin=*/
			{0, 0},
			/*rotation=*/
			0,
			cmd.tint,
		)
	}

	for cmd in renMan.shadow {
		texData, err := texture.GetTexture(texMan, cmd.texture)

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", cmd.texture, panic = false)
			continue
		}

		destRect := core.MakeRect(cmd.dest, core.GetSize(cmd.src) * cmd.zoom)
		rl.DrawTexturePro(
			texData,
			cmd.src,
			destRect,
			/*origin=*/
			{0, 0},
			/*rotation=*/
			0,
			/*tint=*/
			rl.WHITE,
		)
	}

	for cmd in renMan.object {
		texData, err := texture.GetTexture(texMan, cmd.texture)

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", cmd.texture, panic = false)
			continue
		}

		destRect := core.MakeRect(cmd.dest, core.GetSize(cmd.src) * cmd.zoom)
		rl.DrawTexturePro(
			texData,
			cmd.src,
			destRect,
			/*origin=*/
			{0, 0},
			/*rotation=*/
			0,
			/*tint=*/
			rl.WHITE,
		)
	}

	for cmd in renMan.debug {
		switch cmd.shape {
		case .RECTANGLE:
			{
				rl.DrawRectangleLinesEx(
					cmd.rect,
					/*lineThick=*/
					0.2,
					cmd.color,
				)
			}
		case .CIRCLE:
			{
				rl.DrawCircleLinesV(cmd.dest, cmd.radius, cmd.color)
			}
		}
	}

	clear(&renMan.tile)
	clear(&renMan.object)
	clear(&renMan.debug)
}

FlushUi :: proc(renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	for cmd in renMan.uiSprite {
		texData, err := texture.GetTexture(texMan, cmd.texture)

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", cmd.texture, panic = false)
			continue
		}

		destRect := core.MakeRect(cmd.dest, core.GetSize(cmd.src) * cmd.zoom)
		rl.DrawTexturePro(
			texData,
			cmd.src,
			destRect,
			/*origin=*/
			{0, 0},
			/*rotation=*/
			0,
			/*tint=*/
			rl.WHITE,
		)
	}

	clear(&renMan.uiSprite)
}

Shutdown :: proc(renMan: ^RenderManager) {
	delete(renMan.tile)
	delete(renMan.object)
	delete(renMan.debug)
	delete(renMan.uiSprite)
}
