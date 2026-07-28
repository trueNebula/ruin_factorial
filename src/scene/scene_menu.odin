package scene

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
loadMenuScene :: proc(sceneMan: ^SceneManager) {
	triggerSceneTransition(sceneMan, .MENU)
}

@(private)
updateMenuScene :: proc(sceneMan: ^SceneManager) {
	// set data for current frame

}

@(private)
unloadMenuScene :: proc(sceneMan: ^SceneManager) {

}

@(private)
drawMenuScene :: proc(sceneMan: ^SceneManager) {
	{
		rl.DrawRectanglePro(
			rl.Rectangle{x = 0, y = 0, width = 64, height = 64},
			{0, 0},
			0.0,
			rl.GREEN,
		)
	}
}
