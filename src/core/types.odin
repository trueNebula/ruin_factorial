package core

import rl "vendor:raylib"

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
