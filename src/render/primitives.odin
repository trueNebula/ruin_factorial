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

// TODO: handle anchor
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
	size: rl.Vector2 = {},
	zoom: f32 = 1.0,
	tint: rl.Color = rl.WHITE,
) {
	texData, err := texture.GetTexture(texMan, texId)

	if (err) {
		log.Err("Unable to get texture with ID %s. Unloaded?", texId, panic = false)
		return
	}

	rectSize := core.GetSize(src)
	if size != {} {
		rectSize = size
	}

	destRect := core.MakeRect(dest, rectSize * zoom)
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

DrawRect :: proc(rect: rl.Rectangle, fill: rl.Color, outline: rl.Color, outlineW: f32) {
	if fill.a != 0 {
		rl.DrawRectanglePro(rect, {0, 0}, 0, fill)
	}

	if outlineW > 0 && outline.a != 0 {
		rl.DrawRectangleLinesEx(rect, outlineW, outline)
	}
}

DrawNineSlice :: proc(
	texMan: ^texture.TextureManager,
	ns: core.NineSlice,
	pos: rl.Vector2,
	size: rl.Vector2,
	tint: rl.Color = rl.WHITE,
) {
	tex, err := texture.GetTexture(texMan, ns.texture)
	if err {
		return
	}

	scale := f32(max(ns.scale, 1))
	dest := core.MakeRect(pos, size)
	src := ns.rect
	border := ns.border
	scaled := core.Edges {
		border.bottom * scale,
		border.left * scale,
		border.right * scale,
		border.top * scale,
	}

	sx := [3]f32{src.x, src.x + border.left, src.x + src.width - border.right}
	sw := [3]f32{border.left, src.width - border.left - border.right, border.right}
	sy := [3]f32{src.y, src.y + border.top, src.y + src.height - border.bottom}
	sh := [3]f32{border.top, src.height - border.top - border.bottom, border.bottom}

	dx := [3]f32{dest.x, dest.x + scaled.left, dest.x + dest.width - scaled.right}
	dw := [3]f32{scaled.left, dest.width - scaled.left - scaled.right, scaled.right}
	dy := [3]f32{dest.y, dest.y + scaled.top, dest.y + dest.height - scaled.bottom}
	dh := [3]f32{scaled.top, dest.height - scaled.top - scaled.bottom, scaled.bottom}

	tile := ns.mode == .TILE

	for row in 0 ..< 3 {
		for col in 0 ..< 3 {
			s := rl.Rectangle{sx[col], sy[row], sw[col], sh[row]}
			d := rl.Rectangle{dx[col], dy[row], dw[col], dh[row]}
			if s.width <= 0 || s.height <= 0 || d.width <= 0 || d.height <= 0 {
				continue
			}

			if !tile {
				rl.DrawTexturePro(
					tex,
					s,
					d,
					/*origin=*/
					{0, 0},
					/*rotation=*/
					0,
					tint,
				)
			} else {
				tileW := s.width * scale
				tileH := s.height * scale

				for y := d.y; y < d.y + d.height; y += tileH {
					height := min(tileH, d.y + d.height - y)
					for x := d.x; x < d.x + d.width; x += tileW {
						width := min(tileW, d.x + d.width - x)
						rl.DrawTexturePro(
							tex,
							{s.x, s.y, width / scale, height / scale},
							{x, y, width, height},
							/*origin=*/
							{0, 0},
							/*rotation=*/
							0,
							tint,
						)
					}
				}
			}
		}
	}

}
