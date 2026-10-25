package components

import "src:core"
import "src:ui"
import rl "vendor:raylib"

MenuAction :: enum {
	NONE,
	START,
	START_SEEDED,
	SETTINGS,
	EXIT,
}

MainMenu :: proc(uiMan: ^ui.UiManager) -> (action: MenuAction) {
	if ui.Root(
		uiMan,
		"main_menu",
		.MENU,
		ui.Screen{placement = {pivot = core.CL, target = core.CL, offset = {16, 0}}},
	) {
		if ui.Box(
			uiMan,
			"menu_stack",
			{
				layout = .COLUMN,
				gap = 4,
				padding = pad(8),
				background = ui.FlatBackground{fill = rl.BEIGE},
			},
		) {
			if ui.Button(uiMan, "Start", MenuButtonStyle).clicked do action = .START
			if ui.Button(uiMan, "Load", MenuButtonStyle).clicked do action = .START_SEEDED
			if ui.Button(uiMan, "Settings", MenuButtonStyle).clicked do action = .SETTINGS
			if ui.Button(uiMan, "Exit", MenuButtonStyle).clicked do action = .EXIT
		}
	}
	return
}
