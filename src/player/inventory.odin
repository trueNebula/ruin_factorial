package player

import "src:core"

MAX_STACK_SIZE :: 9999

@(private)
tryAddItemToInventory :: proc(inventory: ^core.Inventory, item: core.Item) -> (added: bool) {
	item := item
	for &slot in inventory.slots {
		if item.count == 0 do break
		if slot.id != item.id do continue

		toFillStack := MAX_STACK_SIZE - slot.count
		if toFillStack <= 0 do continue

		toAdd := min(toFillStack, item.count)
		slot.count += toAdd
		item.count -= toAdd
		added = true
	}

	for &slot in inventory.slots {
		if item.count == 0 do break
		if slot.id != .NONE do continue

		toAdd := min(MAX_STACK_SIZE, item.count)
		slot.id = item.id
		slot.count = toAdd
		item.count -= toAdd
		added = true
	}

	return item.count == 0
}
