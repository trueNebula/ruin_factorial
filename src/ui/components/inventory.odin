package components

import "core:fmt"
import "src:core"
import "src:item"
import "src:ui"
import rl "vendor:raylib"

Inventory :: proc(uiMan: ^ui.UiManager, state: ui.InventoryState) {
	if ui.Root(
		uiMan,
		"inventory",
		.MENU,
		{placement = {target = core.BC, pivot = core.BC, offset = {0, 0}}},
	) {
		if ui.Box(
			uiMan,
			"inventory_container",
			{
				layout = .COLUMN,
				size = {{.FIXED, 350}, {.FIXED, 146}},
				background = ContainerNS,
				padding = pad(6),
				gap = 2,
			},
		) {
			for row in 0 ..< state.rows {
				if ui.Box(
					uiMan,
					fmt.tprintf("inventory_row_%u", row),
					{layout = .ROW, gap = 2, size = {{.GROW, 1}, {.FIXED, 32}}},
				) {
					for slot, idx in state.slots[row * 10:(row + 1) * 10] {
						if response, open := ui.ClickableBox(
							uiMan,
							fmt.tprintf("inventory_slot_%u", idx),
							{
								size = {{.FIXED, 32}, {.FIXED, 32}},
								background = ui.SpriteBackground {
									sprite = {texture = .UI, rect = {0, 0, 16, 16}},
								},
							},
						); open {
							opts := ui.BoxOpts {
								size = {{.FIXED, 32}, {.FIXED, 32}},
							}
							if slot.id != .NONE {
								itemRect, err := item.GetRectForId(slot.id)
								if !err {
									opts.background = ui.SpriteBackground {
										sprite = {texture = .ITEM, rect = itemRect},
									}
								}
							}
							if ui.Box(uiMan, fmt.tprintf("inventory_slot_%u_itm", idx), opts) {
								if slot.id != .NONE || slot.count > 0 {
									ui.Label(
										uiMan,
										fmt.tprintf("inventory_slot_%u_cnt", idx),
										fmt.tprint(slot.count),
										InventorySlotCountStyle,
										{target = core.TR, pivot = core.TR, offset = {-3, 2}},
									)
								}
								if response.hovered {
									ui.Scrim(uiMan, fmt.tprintf("inventory_slot_%u_scrim", idx))
								}
								if response.clicked {
									fmt.println("Clicked", response.rect)
								}
							}
						}
					}
				}
			}
		}
	}
}
