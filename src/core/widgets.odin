package core

import rl "vendor:raylib"

WidgetAnchor :: rl.Vector2 // x,y [0..1], 1 is BR

WidgetPlacement :: struct {
	target: WidgetAnchor, // where on the screen to place the pivot
	pivot:  WidgetAnchor, // where on the sprite the pivot is
	offset: rl.Vector2, // 2D offset to add after placing
}

TL :: WidgetAnchor{0, 0}
TC :: WidgetAnchor{0.5, 0}
TR :: WidgetAnchor{1, 0}
CL :: WidgetAnchor{0, 0.5}
CC :: WidgetAnchor{0.5, 0.5}
CR :: WidgetAnchor{1, 0.5}
BL :: WidgetAnchor{0, 1}
BC :: WidgetAnchor{0.5, 1}
BR :: WidgetAnchor{1, 1}

PlaceWidget :: proc(
	placement: WidgetPlacement,
	size: rl.Vector2,
	parent: rl.Rectangle,
) -> rl.Vector2 {
	return {
		parent.width * placement.target.x - size.x * placement.pivot.x + placement.offset.x,
		parent.height * placement.target.y - size.y * placement.pivot.y + placement.offset.y,
	}
}
