package ui

import "core:fmt"
import "core:hash"
import "core:math"
import "src:core"
import "src:render"
import "src:texture"
import rl "vendor:raylib"

@(private)
makeId :: proc(uiMan: ^UiManager, label: string) -> Id {
	seed := u64(0xd6a6468d2a0dff09)
	return Id(hash.fnv64a(transmute([]byte)label, seed))
}

@(private)
contentSize :: proc(node: ^Node, texMan: ^texture.TextureManager) -> rl.Vector2 {
	switch content in node.content {
	case TextContent:
		fontData, err := texture.GetFont(texMan, content.style.font)
		if err {
			return {0, 0}
		}

		size := rl.MeasureTextEx(
			fontData.resource,
			fmt.ctprint(content.str),
			content.style.size,
			fontData.spacing,
		)

		return {math.ceil(size.x), math.ceil(size.y)}
	case ImageContent:
		return core.GetSize(content.sprite.rect) * f32(content.scale)
	}
	return {0, 0}
}

@(private)
sizeAxis :: proc(size: Size, fit: f32) -> f32 {
	switch size.kind {
	case .FIT:
		return fit
	case .FIXED:
		return size.v
	}
	return 0
}

@(private)
addChild :: proc(parent: ^Node, boxSize: [2]Size, nodeSize: rl.Vector2) {
	gap := parent.childCount > 0 ? parent.opts.gap : 0
	switch parent.opts.layout {
	case .ROW:
		parent.childrenSize.x += nodeSize.x + gap
		parent.childrenSize.y = max(parent.childrenSize.y, nodeSize.y)
	case .COLUMN:
		parent.childrenSize.x = max(parent.childrenSize.x, nodeSize.x)
		parent.childrenSize.y += nodeSize.y + gap
	case .NONE:
		parent.childrenSize = {
			max(parent.childrenSize.x, nodeSize.x),
			max(parent.childrenSize.y, nodeSize.y),
		}
	}
	parent.childCount += 1
}

@(private)
placeRoot :: proc(uiMan: ^UiManager, node: ^Node) -> rl.Vector2 {
	screen := GetScreen(uiMan)
	// TODO: add code to attach root to world
	return core.PlaceWidget(node.opts.placement, node.size, screen)
}

@(private)
placeChild :: proc(parent: ^Node, child: ^Node) -> rl.Vector2 {
	padding := child.opts.padding
	paddedRect := rl.Rectangle {
		parent.position.x + padding.left,
		parent.position.y + padding.top,
		parent.size.x - padding.left - padding.right,
		parent.size.y - padding.top - padding.bottom,
	}
	position: rl.Vector2

	switch parent.opts.layout {
	case .NONE:
		position = core.PlaceWidget(child.opts.placement, child.size, paddedRect)
	case .ROW:
		position = {
			parent.cursor.x,
			parent.cursor.y + align(parent.opts.align, paddedRect.height, child.size.y),
		}
		parent.cursor.x += child.size.x + parent.opts.gap
	case .COLUMN:
		position = {
			parent.cursor.x + align(parent.opts.align, paddedRect.width, child.size.x),
			parent.cursor.y,
		}
		parent.cursor.y += child.size.y + parent.opts.gap
	}

	return position
}

@(private)
align :: proc(alignment: core.Align, parentLen: f32, childLen: f32) -> f32 {
	switch alignment {
	case .START:
		return 0
	case .CENTER:
		return math.round((parentLen - childLen) / 2)
	case .END:
		return parentLen - childLen
	}

	return 0
}

@(private)
addNode :: proc(uiMan: ^UiManager, id: Id, opts: BoxOpts) -> int {
	parent := -1
	node := Node {
		id     = id,
		parent = parent,
		opts   = opts,
	}

	if len(uiMan.parents) > 0 {
		parent = uiMan.parents[len(uiMan.parents) - 1]
		node.parent = parent
		node.layer = uiMan.nodes[parent].layer
		node.space = uiMan.nodes[parent].space
	}

	append(&uiMan.nodes, node)
	return len(uiMan.nodes) - 1
}

@(private)
pushNode :: proc(uiMan: ^UiManager, id: Id, opts: BoxOpts) -> int {
	index := addNode(uiMan, id, opts)
	append(&uiMan.parents, index)
	return index
}

@(private)
popNode :: proc(uiMan: ^UiManager) {
	pop(&uiMan.parents)
}

@(private)
touch :: proc(uiMan: ^UiManager, id: Id) -> ^WidgetState {
	if id not_in uiMan.widgets {
		uiMan.widgets[id] = {}
	}

	state := &uiMan.widgets[id]
	state.lastSeen = uiMan.frame

	return state
}

@(private)
respond :: proc(uiMan: ^UiManager, id: Id) -> Response {
	return Response {
		hovered = uiMan.hovered == id,
		active = uiMan.active == id,
		clicked = uiMan.clicked == id,
		rect = uiMan.widgets[id].rect,
	}
}

@(private)
drawNode :: proc(node: ^Node, texMan: ^texture.TextureManager) {
	switch bg in node.opts.background {
	case FlatBackground:
		rect := core.MakeRect(node.position, node.size)
		render.DrawRect(rect, bg.fill, bg.outline, bg.outlineW)
	case SpriteBackground:
		dt := rl.GetFrameTime()
		sprite := bg.sprite
		animation := bg.animation
		frame := sprite.rect

		if len(animation.frames) > 0 {
			animation.timer += dt
			if animation.timer >= animation.frames[animation.index].duration {
				animation.timer -= animation.frames[animation.index].duration
				animation.index += 1
			}
			frame = animation.frames[animation.index].rect
		}

		rectSize := rl.Vector2{}
		if node.opts.size[0].kind == .FIXED || node.opts.size[1].kind == .FIXED {
			rectSize = {node.opts.size[0].v, node.opts.size[1].v}
		}

		render.DrawSprite(texMan, sprite.texture, frame, node.position, rectSize)
	case NineSlice:
	// TODO: implement
	}

	switch c in node.content {
	case TextContent:
		fontData, err := texture.GetFont(texMan, c.style.font)
		if err {
			return
		}

		text := fmt.ctprint(c.str)
		if shadow, ok := c.style.shadow.?; ok {
			render.DrawText(
				text,
				fontData,
				node.position + shadow.offset,
				c.style.size,
				shadow.color,
			)
		}

		render.DrawText(text, fontData, node.position, c.style.size, c.style.color)
	case ImageContent:
		render.DrawSprite(texMan, c.sprite.texture, c.sprite.rect, node.position)
	}
}
