package components

import "core:strings"
import "src:core"
import "src:repository"
import "src:texture"
import "src:ui"
import rl "vendor:raylib"

Tooltip :: proc(uiMan: ^ui.UiManager, texMan: ^texture.TextureManager, item: ^repository.ItemDef) {
	core.Scope("ui.Tooltip")

	id := ui.MakeId(uiMan, "tooltip")
	fontData, _ := texture.GetFont(texMan, .MAIN)
	state, ok := &uiMan.state[id]
	wrapped: string

	if !ok {
		uiMan.state[id] = ui.TooltipState{}
		state = &uiMan.state[id]
	}
	cache := &state.(ui.TooltipState)
	if cache.descCacheKey != item.description {
		delete(cache.descCache)
		cache.descCache = strings.clone(
			core.FitText(item.description, InventorySlotCountStyle, fontData.resource, 288),
		)
		cache.descCacheKey = item.description
	}
	wrapped = cache.descCache

	if ui.Root(
		uiMan,
		"tooltip",
		.TOOLTIP,
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
				size = {{.FIXED, 300}, {.FIT, 0}},
				background = ContainerNS,
				padding = pad(6),
				gap = 4,
			},
		) {
			ui.Label(
				uiMan,
				"tooltip_title",
				item.name,
				InventoryTitleStyle,
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
