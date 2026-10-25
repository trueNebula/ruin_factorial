package repository

import "src:core"
import rl "vendor:raylib"

ItemId :: distinct u32

ItemDef :: struct {
	key:     string,
	name:    string,
	texture: core.Texture,
	rect:    rl.Rectangle,
}

@(private)
resolveItemIds :: proc(repo: ^Repository) {
	append(&repo.itemIds, mustFind(&repo.items, "base:none_item"))
	append(&repo.itemIds, mustFind(&repo.items, "base:wood"))
}

WoodDef :: ItemDef {
	key = "base:wood",
	name = "Wood",
	texture = .ITEM,
	rect = {x = 0, y = 0, width = 16, height = 16},
}

NoneItemDef :: ItemDef{}
