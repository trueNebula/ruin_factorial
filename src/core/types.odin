package core

import rl "vendor:raylib"

Path :: string

Texture :: enum {
	UNKNOWN,
	TEST,
	PLAYER,
	TILE,
	ITEM,
	BLOCK,
}

Anchor :: enum {
	BOTTOM_LEFT,
	CENTER,
	TOP_LEFT,
}

Keybinds :: struct {
	Up, Down, Left, Right: rl.KeyboardKey,
	Inventory, Menu:       rl.KeyboardKey,
	Action, Interact:      rl.MouseButton,
}

InputAction :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	INVENTORY,
	MENU,
}

MouseButton :: enum {
	LEFT,
	RIGHT,
}

WindowProps :: struct {
	width:     i32,
	height:    i32,
	title:     cstring,
	minWidth:  i32,
	minHeight: i32,
}

TileId :: enum {
	NONE,
	WATER,
	SAND,
	DIRT,
	GRASS,
	GRAVEL,
	STONE,
	SNOW,
}

// For debug rendering and colliders
Shape :: enum {
	RECTANGLE,
	CIRCLE,
}

BiomeId :: enum {
	NONE,
	WATER,
	DESERT,
	GRASSLANDS,
}

BlockId :: enum {
	NONE,
	GRASS,
}

ItemId :: enum {
	NONE,
	WOOD,
}

TweenCurve :: enum {
	NONE, // instant a->b
	LINEAR, // linear fade a->b
	EASE_IN, // ease-in fade a->b
	EASE_OUT, // ease-out fade a->b
	EASE_IN_OUT, // ease-in-out fade a->b
}
