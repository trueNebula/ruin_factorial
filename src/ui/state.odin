package ui

import "src:core"

HotbarState :: struct {
	slots:    []core.Item,
	selected: int,
}

InventoryState :: struct {
	slots: []core.Item,
	rows:  int,
}
