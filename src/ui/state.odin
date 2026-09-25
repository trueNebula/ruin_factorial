package ui

import "src:core"

State :: union {
	HotbarState,
	InventoryState,
}

StateMap :: map[ComponentId]State

InventoryState :: struct {}

HotbarState :: struct {
	slots:    []core.Item,
	size:     int,
	selected: int,
}
