package engine

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
loadMenuScene :: proc(engine: ^Engine) {
	triggerSceneTransition(engine, .MENU)
}

@(private)
updateMenuScene :: proc(engine: ^Engine) {
	// set data for current frame

}

@(private)
unloadMenuScene :: proc(engine: ^Engine) {

}

@(private)
drawMenuScene :: proc(engine: ^Engine) {
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.GREEN,
		)
	}
}
