package repository

import "src:core"
import rl "vendor:raylib"

ItemDef :: struct {
	key:         string,
	name:        string,
	description: string,
	texture:     core.Texture,
	rect:        rl.Rectangle,
}

NoneItemDef :: ItemDef {
	texture = .ITEM,
	rect    = {0, 0, 16, 16},
}

BlockDef :: struct {
	key:      string,
	health:   int,
	drops:    core.DropTable,
	texture:  core.Texture,
	anchor:   core.Anchor,
	flags:    core.BlockFlags,
	tiles:    []core.TileOffset,
	rect:     rl.Rectangle,
	collider: core.Collider,
	storage:  int,
}

NoneBlockDef :: BlockDef {
	health  = 1,
	texture = .BLOCK,
	rect    = {0, 0, 16, 16},
}

RecipeDef :: struct {
	key:    string,
	input:  []core.KeyedItem,
	output: []core.KeyedItem,
	source: core.RecipeSource,
}

KeyedItem2Item :: proc(repo: ^Repository, keyedItem: ^core.KeyedItem) -> core.Item {
	id, err := Find(&repo.items, keyedItem.item)
	if err do return {}

	return {id = id, count = keyedItem.count}
}
