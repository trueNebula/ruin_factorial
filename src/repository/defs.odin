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

BlockDef :: struct {
	key:     string,
	health:  int,
	drops:   core.DropTable,
	texture: core.Texture,
	anchor:  core.Anchor,
	rect:    rl.Rectangle,
}

NoneBlockDef :: BlockDef {
	health  = 1,
	texture = .BLOCK,
	rect    = {0, 0, 16, 16},
}
