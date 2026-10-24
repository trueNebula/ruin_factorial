package components

import "core:fmt"
import "src:core"
import "src:item"
import "src:ui"
import rl "vendor:raylib"

Hotbar :: proc(uiMan: ^ui.UiManager, state: ui.HotbarState) {
	if ui.Root(
		uiMan,
		"hotbar",
		.HUD,
		{placement = {target = core.BC, pivot = core.CC, offset = {0, -32}}},
	) {
		if ui.Box(
			uiMan,
			"hotbar_container",
			{
				layout = .ROW,
				size = {{.FIXED, 350}, {.FIXED, 44}},
				background = ui.SpriteBackground {
					sprite = {texture = .UI_HOTBAR, rect = {0, 0, 175, 22}},
				},
				padding = pad(6),
				gap = 2,
			},
		) {
			for slot, idx in state.slots {
				if slot.id == .NONE {
					continue
				}
				itemRect, err := item.GetRectForId(slot.id)
				if err {
					continue
				}

				if ui.Box(
					uiMan,
					fmt.tprintf("hotbar_slot_%u", idx),
					{
						background = ui.SpriteBackground {
							sprite = {texture = .ITEM, rect = itemRect},
						},
						size = {{.FIXED, 32}, {.FIXED, 32}},
					},
				) {
					ui.Label(
						uiMan,
						fmt.tprintf("hotbar_slot_%u_cnt", idx),
						fmt.tprint(slot.count),
						InventorySlotCountStyle,
						{target = core.TR, pivot = core.TR, offset = {-3, 2}},
					)
				}
			}
		}
	}
}
