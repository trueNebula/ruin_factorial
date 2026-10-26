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

// Add item ids to the repo list in the same order as the enum values for core.ItemId
@(private)
resolveItemIds :: proc(repo: ^Repository) {
	append(&repo.itemIds, mustFind(&repo.items, "base:none_item"))
	append(&repo.itemIds, mustFind(&repo.items, "base:wood"))
}

NoneItemDef :: ItemDef {
	texture = .ITEM,
	rect    = {0, 0, 16, 16},
}
