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
