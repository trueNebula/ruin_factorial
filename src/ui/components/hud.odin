package components

import "core:fmt"
import "src:core"
import "src:repository"
import "src:ui"
import rl "vendor:raylib"

Hotbar :: proc(uiMan: ^ui.UiManager, repo: ^repository.Repository, state: ui.HotbarState) {
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
				background = ContainerNS,
				padding = pad(6),
				gap = 2,
			},
		) {
			for slot, idx in state.slots {
				if ui.Box(
					uiMan,
					fmt.tprintf("hotbar_slot_%u", idx),
					{size = {{.FIXED, 32}, {.FIXED, 32}}, background = ContainerSlotSprite},
				) {
					opts := ui.BoxOpts {
						size = {{.FIXED, 32}, {.FIXED, 32}},
					}
					if slot.id != .NONE {
						itemDef := repository.Get(&repo.items, repo.itemIds[slot.id])
						opts.background = ui.SpriteBackground {
							sprite = {texture = itemDef.texture, rect = itemDef.rect},
						}
					}
					if ui.Box(uiMan, fmt.tprintf("hotbar_slot_%u_itm", idx), opts) {
						if slot.id != .NONE || slot.count > 0 {
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
	}
}
