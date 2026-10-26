package repository

import "src:core"
import rl "vendor:raylib"

ItemDef :: struct {
	key:     string,
	name:    string,
	texture: core.Texture,
	rect:    rl.Rectangle,
}

NoneItemDef :: ItemDef {
	texture = .ITEM,
	rect    = {0, 0, 16, 16},
}
