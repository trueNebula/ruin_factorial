package render

import "core:sort"
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
	ySortSprites(renMan)

	for cmd in renMan.tile {
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
			cmd.tint,
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

Shutdown :: proc(renMan: ^RenderManager) {
	delete(renMan.tile)
	delete(renMan.object)
	delete(renMan.debug)
	delete(renMan.uiSprite)
}

@(private)
ySortSprites :: proc(renMan: ^RenderManager) {
	sort.quick_sort_proc(renMan.object[:], proc(a: DrawCommand, b: DrawCommand) -> int {
		aSize := core.GetSize(a.src) * a.zoom
		bSize := core.GetSize(b.src) * b.zoom
		return int((a.dest.y + aSize.y - core.TileSize) - (b.dest.y + bSize.y - core.TileSize))
	})
}
