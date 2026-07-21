package managers

import rl "vendor:raylib"

Menu :: enum {
	MAIN,
	OPTIONS,
	CREATE_WORLD,
	MANAGE_SAVES,
}

MenuScene :: struct {
	menu: Menu,
}

@(private)
initMenuScene :: proc() -> MenuScene {
	return MenuScene{menu = .MAIN}
}

@(private)
loadMenuScene :: proc(manager: ^SceneManager) {
	triggerSceneTransition(manager, .MENU)
}

@(private)
updateMenuScene :: proc(manager: ^SceneManager) {
	// set data for current frame

}

@(private)
drawMenuScene :: proc(manager: ^SceneManager) {
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.GREEN,
		)
	}
}
