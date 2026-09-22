package player

import "src:core"

MAX_STACK_SIZE :: 9999

@(private)
tryAddItemToInventory :: proc(inventory: ^core.Inventory, item: core.Item) -> (added: bool) {
	item := item
	for &slot in inventory.slots {
		if slot.id == item.id {
			if slot.count + item.count > MAX_STACK_SIZE {
				toFillStack := MAX_STACK_SIZE - slot.count
				remainder := item.count - toFillStack

				slot.count = MAX_STACK_SIZE
				item.count = remainder
				continue
			} else {
				slot.count += item.count
				return true
			}
		} else if slot.id == .NONE {
			slot = item
			return true
		}
	}
	return false
}
