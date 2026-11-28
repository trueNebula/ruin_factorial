package components

import "core:fmt"
import "core:prof/spall"
import "core:strings"
import "src:core"
import "src:repository"
import "src:texture"
import "src:ui"
import rl "vendor:raylib"

InventoryProps :: struct {
	slots: []core.Item,
}

Inventory :: proc(
	uiMan: ^ui.UiManager,
	repo: ^repository.Repository,
	texMan: ^texture.TextureManager,
	props: InventoryProps,
) -> (
	clickedIdx: Maybe(int),
	mouseButton: Maybe(core.MouseButton),
) {
	core.Scope("ui.Inventory")

	hoveredItem: ^repository.ItemDef
	clickedIdx = nil
	mouseButton = nil
	rows := len(props.slots) / 10

	if ui.Root(
		uiMan,
		"inventory",
		.MENU,
		ui.Screen{placement = {target = core.BC, pivot = core.BC, offset = {0, 0}}},
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
			for row in 0 ..< rows {
				core.Scope("ui.Inventory.row")
				if ui.Box(
					uiMan,
					fmt.tprintf("inventory_row_%u", row),
					{layout = .ROW, gap = 2, size = {{.GROW, 1}, {.FIXED, 32}}},
				) {
					for slot, idx in props.slots[row * 10:(row + 1) * 10] {
						core.Scope("ui.Inventory.slot")

						if response, open := ui.ClickableBox(
							uiMan,
							fmt.tprintf("inventory_slot_%u", idx),
							{
								size = {{.FIXED, 32}, {.FIXED, 32}},
								background = ContainerSlotSprite,
							},
						); open {
							opts := ui.BoxOpts {
								size = {{.FIXED, 32}, {.FIXED, 32}},
							}

							if !core.IsNone(slot.id) {
								itemDef := repository.Get(&repo.items, slot.id)
								opts.background = ui.SpriteBackground {
									sprite = {texture = itemDef.texture, rect = itemDef.rect},
								}
								if response.hovered do hoveredItem = itemDef
							}

							if ui.Box(uiMan, fmt.tprintf("inventory_slot_%u_itm", idx), opts) {
								core.Scope("ui.Inventory.count")

								if !core.IsNone(slot.id) || slot.count > 0 {
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
									clickedIdx = row * 10 + idx
									mouseButton = .LEFT
								}

								if response.clickedR {
									clickedIdx = row * 10 + idx
									mouseButton = .RIGHT
								}
							}
						}
					}
				}
			}
		}
	}

	if hoveredItem != nil {
		Tooltip(uiMan, texMan, hoveredItem)
	}

	return
}

InventoryCraftingProps :: struct {
	recipes: []core.Recipe,
}

InventoryCrafting :: proc(
	uiMan: ^ui.UiManager,
	texMan: ^texture.TextureManager,
	props: InventoryCraftingProps,
) {

}
