package render

import "core:fmt"
import "src:core"
import "src:log"
import "src:texture"
import rl "vendor:raylib"

/** 
 * Queue Functions
 * These get batched and drawn in Flush()
 */
QueueSprite :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	sortY: bool,
	zoom: f32 = 1.0,
	tint: rl.Color = rl.WHITE,
) {
	append(
		&renMan.object,
		DrawCommand {
			texture = texture,
			src = src,
			dest = dest,
			sortY = sortY,
			zoom = zoom,
			tint = tint,
		},
	)
}

QueueShadow :: proc(
	renMan: ^RenderManager,
	shadow: core.Shadow,
	dest: rl.Vector2,
	zoom: f32 = 1.0,
	tint: rl.Color = rl.WHITE,
) {
	src: rl.Rectangle

	switch shadow {
	case .SMALL:
		src = {
			x      = 240,
			y      = 0,
			width  = 16,
			height = 16,
		}
	case .LARGE:
		src = {
			x      = 224,
			y      = 0,
			width  = 16,
			height = 16,
		}
	}

	dest := dest
	dest.y += core.TileSize / 4

	append(
		&renMan.object,
		DrawCommand {
			texture = .ITEM,
			src = src,
			dest = dest,
			sortY = false,
			zoom = zoom,
			tint = tint,
		},
	)
}

QueueTile :: proc(
	renMan: ^RenderManager,
	texture: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	zoom: f32 = 1.0,
	tint: rl.Color = rl.WHITE,
) {
	append(
		&renMan.tile,
		DrawCommand {
			texture = texture,
			src = src,
			dest = dest,
			sortY = false,
			zoom = zoom,
			tint = tint,
		},
	)
}

QueueRect :: proc(renMan: ^RenderManager, rect: rl.Rectangle, color: rl.Color) {
	append(&renMan.debug, ShapeDrawCommand{shape = .RECTANGLE, rect = rect, color = color})
}

QueueCircle :: proc(renMan: ^RenderManager, center: rl.Vector2, radius: f32, color: rl.Color) {
	append(
		&renMan.debug,
		ShapeDrawCommand{shape = .CIRCLE, dest = center, radius = radius, color = color},
	)
}

/**
 * Draw Functions
 * These get drawn to the screen instantly.
 */
DrawSprite :: proc(
	texMan: ^texture.TextureManager,
	texId: core.Texture,
	src: rl.Rectangle,
	dest: rl.Vector2,
	zoom: f32 = 1.0,
	tint: rl.Color = rl.WHITE,
) {
	texData, err := texture.GetTexture(texMan, texId)

	if (err) {
		log.Err("Unable to get texture with ID %s. Unloaded?", texId, panic = false)
		return
	}

	destRect := core.MakeRect(dest, core.GetSize(src) * zoom)
	rl.DrawTexturePro(
		texData,
		src,
		destRect,
		/*origin=*/
		{0, 0},
		/*rotation=*/
		0,
		tint,
	)
}

DrawText :: proc(
	text: cstring,
	fontData: texture.FontData,
	dest: rl.Vector2,
	size: f32,
	tint: rl.Color = rl.WHITE,
) {
	rl.DrawTextPro(
		fontData.resource, // rl.GetFontDefault(),
		text,
		dest,
		/*origin=*/
		{0, 0},
		/*rotation=*/
		0,
		size,
		fontData.spacing,
		tint,
	)
}
