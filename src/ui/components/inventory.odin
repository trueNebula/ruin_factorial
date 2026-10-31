package components

import "core:fmt"
import "src:core"
import "src:repository"
import "src:texture"
import "src:ui"
import rl "vendor:raylib"

InventoryProps :: struct {
	slots: []core.Item,
	rows:  int,
}

Inventory :: proc(
	uiMan: ^ui.UiManager,
	repo: ^repository.Repository,
	texMan: ^texture.TextureManager,
	props: InventoryProps,
) {
	hoveredItem: ^repository.ItemDef

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
			for row in 0 ..< props.rows {
				if ui.Box(
					uiMan,
					fmt.tprintf("inventory_row_%u", row),
					{layout = .ROW, gap = 2, size = {{.GROW, 1}, {.FIXED, 32}}},
				) {
					for slot, idx in props.slots[row * 10:(row + 1) * 10] {
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
									fmt.println("Clicked", response.rect)
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
}

Tooltip :: proc(uiMan: ^ui.UiManager, texMan: ^texture.TextureManager, item: ^repository.ItemDef) {
	id := ui.MakeId(uiMan, "tooltip")
	desc := "this is a long string to test the text wrapping algorithm. this should handle well.\nnew lines should also be handled"
	fontData, _ := texture.GetFont(texMan, .MAIN)
	// cache, err := ui.GetState(uiMan, ui.TooltipState, id)
	state, ok := &uiMan.state[id]
	wrapped: string

	if !ok {
		uiMan.state[id] = ui.TooltipState{}
		state = &uiMan.state[id]
	}
	cache := state.(ui.TooltipState)
	if cache.descCacheKey != desc {
		cache.descCache = core.FitText(desc, InventorySlotCountStyle, fontData.resource, 150)
	}
	wrapped = cache.descCache

	if ui.Root(
		uiMan,
		"tooltip",
		.MENU,
		ui.Follow {
			pos = uiMan.mouse[ui.Space.SCREEN],
			pivot = core.BC,
			clamp = true,
			offset = {0, -9},
		},
	) {
		if ui.Box(
			uiMan,
			"tooltip_container",
			{
				layout = .COLUMN,
				size = {{.FIXED, 162}, {.FIT, 0}},
				background = ContainerNS,
				padding = pad(6),
			},
		) {
			ui.Label(
				uiMan,
				"tooltip_title",
				item.name,
				InventorySlotCountStyle,
				{target = core.TR, pivot = core.TR},
			)
			ui.Label(
				uiMan,
				"tooltip_description",
				wrapped,
				InventorySlotCountStyle,
				{target = core.TR, pivot = core.TR},
			)
		}
	}
}
