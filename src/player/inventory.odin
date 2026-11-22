package player

import "core:fmt"
import "src:core"
import "src:log"

MAX_STACK_SIZE :: 9999
MOUSE_SLOT :: 40

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
		if !core.IsNone(slot.id) do continue

		toAdd := min(MAX_STACK_SIZE, item.count)
		slot.id = item.id
		slot.count = toAdd
		item.count -= toAdd
		added = true
	}

	return item.count == 0
}

OnInventorySlotClicked :: proc(inventory: ^core.Inventory, idx: int, alternate: bool) {
	// fmt.printfln("Slot %d", idx)
	if len(inventory.slots) < MOUSE_SLOT {
		log.Err("Tried getting mouse slot for inventory other than player's, not implemneted")
	}
	mouseItem := inventory.slots[MOUSE_SLOT]
	slot := inventory.slots[idx]

	swap :: proc(mouseItem: core.Item, slot: core.Item, inventory: ^core.Inventory, idx: int) {
		tmp := mouseItem
		inventory.slots[idx] = {tmp.id, tmp.count}
		inventory.slots[MOUSE_SLOT] = {slot.id, slot.count}
	}


	if alternate {
		// RMB
		if core.IsNone(mouseItem.id) && !core.IsNone(slot.id) {
			if slot.count == 1 do swap(mouseItem, slot, inventory, idx)
			else {
				mouseSlotQty := slot.count / 2 if slot.count % 2 == 0 else slot.count / 2 + 1
				inventory.slots[MOUSE_SLOT] = {slot.id, mouseSlotQty}
				inventory.slots[idx].count -= mouseSlotQty
			}
		}
	} else {
		// LMB	
		if mouseItem.id != slot.id {
			swap(mouseItem, slot, inventory, idx)
		} else {
			total := mouseItem.count + slot.count
			if total <= MAX_STACK_SIZE {
				inventory.slots[idx].count = total
				inventory.slots[MOUSE_SLOT] = {}
			} else {
				inventory.slots[idx].count = MAX_STACK_SIZE
				inventory.slots[MOUSE_SLOT].count = total - MAX_STACK_SIZE
			}
		}
	}
}
