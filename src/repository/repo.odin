package repository

import "core:mem"
import "core:mem/virtual"
import "src:core"
import "src:log"

Repository :: struct {
	arena:   virtual.Arena,
	items:   Registry(ItemDef, ItemId),
	itemIds: [dynamic]ItemId,
}

Registry :: struct($Def: typeid, $Id: typeid) {
	defs:  [dynamic]Def,
	byKey: map[string]Id,
}

MakeRepository :: proc() -> Repository {
	return {
		items = Registry(ItemDef, ItemId) {
			defs = make([dynamic]ItemDef),
			byKey = make(map[string]ItemId),
		},
		itemIds = make([dynamic]ItemId),
	}
}

Shutdown :: proc(repo: ^Repository) {
	virtual.arena_destroy(&repo.arena)
	delete(repo.itemIds)
	delete(repo.items.defs)
	delete(repo.items.byKey)
}

InitializeRepo :: proc(repo: ^Repository) {
	readRepo(repo)

	Register(&repo.items, "base:none_item", NoneItemDef)

	resolveItemIds(repo)
}

// Register a def by key
// Use when loading the entire repo
Register :: proc(reg: ^Registry($D, $I), key: string, def: D) -> (id: I, err: bool) {
	if key in reg.byKey {
		return {}, true
	}

	append(&reg.defs, def)
	id = I(len(reg.defs) - 1)
	reg.byKey[key] = id

	return id, false
}

// Get id by key
// Use when resolving references, for example for a recipe needing the item id
Find :: proc(reg: ^Registry($D, $I), key: string) -> (id: I, err: bool) {
	if key not_in reg.byKey {
		return 0, true
	}

	return reg.byKey[key], false
}

// Get the def by id
// Use when you need the actual def data, such as getting the rect for an item id
Get :: proc(reg: ^Registry($D, $I), id: I) -> ^D {
	return &reg.defs[id]
}

@(private)
mustFind :: proc(reg: ^Registry($D, $I), key: string) -> I {
	id, err := Find(reg, key)
	if err {
		log.Err("Repository: Required id \"%v\" is missing.", id)
	}
	return id
}

@(private)
allocator :: proc(repo: ^Repository) -> mem.Allocator {
	return virtual.arena_allocator(&repo.arena)
}
