package ui

import "src:core"
import rl "vendor:raylib"

Id :: distinct u64
Layer :: enum {
	HUD,
	MENU,
}
Space :: enum {
	WORLD,
	SCREEN,
}

Layout :: enum {
	NONE,
	ROW,
	COLUMN,
}

Size :: struct {
	kind: Sizing,
	v:    f32,
}

Sizing :: enum {
	FIT, // Size to content, v unused
	FIXED, // v UI px
	GROW, // Grow to leftover space, v is weight
}

BoxOpts :: struct {
	size:       [2]Size,
	layout:     Layout,
	gap:        f32,
	padding:    core.Edges,
	align:      core.Align,
	placement:  core.WidgetPlacement,
	capture:    bool,
	background: Background,
}

Node :: struct {
	id:           Id,
	parent:       int,
	layer:        Layer,
	space:        Space,
	padding:      core.Edges,
	size:         rl.Vector2,
	growSum:      f32,
	position:     rl.Vector2,
	childrenSize: rl.Vector2, // Running size of the children
	childCount:   int, // For gaps
	cursor:       rl.Vector2, // Where the next child will go
	opts:         BoxOpts,
	content:      Content,
}

Background :: union {
	FlatBackground,
	SpriteBackground,
	NineSlice,
}

FlatBackground :: struct {
	fill:     rl.Color,
	outline:  rl.Color,
	outlineW: f32,
}

SpriteBackground :: struct {
	sprite:    core.Sprite,
	animation: core.Animation,
}

NineSlice :: struct {
	// TODO: add support for this
}

Content :: union {
	TextContent,
	ImageContent,
}

TextContent :: struct {
	str:   string,
	style: core.TextStyle,
}

ImageContent :: struct {
	sprite: core.Sprite,
	scale:  int,
}

Response :: struct {
	hovered: bool, // Cursor over me, topmost, can be clicked on
	active:  bool, // Active, mouse down, waiting for release
	clicked: bool, // Mouse just released, true for one frame
	rect:    rl.Rectangle, // Rect on the previous frame
}

WidgetState :: struct {
	// Bounding box
	rect:                    rl.Rectangle,
	space:                   Space,
	layer:                   Layer,
	// Timers for various animations
	hoverT, pressT, appearT: f32,
	// Z order
	order:                   int,
	// Can be hot or be clicked on
	capture:                 bool,
	// Last frame on which this Widget was built
	lastSeen:                int,
}
