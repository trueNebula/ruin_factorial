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
}

ShapeDrawCommand :: struct {
	shape:  core.Shape,
	rect:   rl.Rectangle,
	radius: f32,
	dest:   rl.Vector2,
	color:  rl.Color,
}

RenderManager :: struct {
	tile:   [dynamic]DrawCommand,
	object: [dynamic]DrawCommand,
	debug:  [dynamic]ShapeDrawCommand,
}

MakeRenderManager :: proc() -> RenderManager {
	tile := make([dynamic]DrawCommand)
	object := make([dynamic]DrawCommand)
	debug := make([dynamic]ShapeDrawCommand)

	return {tile = tile, object = object, debug = debug}
}

Flush :: proc(renMan: ^RenderManager, texMan: ^texture.TextureManager) {
	for cmd in renMan.tile {
		texData, err := texture.GetTexture(texMan, cmd.texture)

		if (err) {
			log.Err("Unable to get texture with ID %s. Unloaded?", cmd.texture, panic = false)
			continue
		}

		destRect := core.MakeRect(cmd.dest, core.GetSize(cmd.src))
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

		destRect := core.MakeRect(cmd.dest, core.GetSize(cmd.src))
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
				rl.DrawRectanglePro(
					cmd.rect,
					/*origin=*/
					{0, 0},
					/*rotation=*/
					0,
					cmd.color,
				)
			}
		case .CIRCLE:
			{
				rl.DrawCircleV(cmd.dest, cmd.radius, cmd.color)
			}
		}
	}

	clear(&renMan.tile)
	clear(&renMan.object)
	clear(&renMan.debug)
}
