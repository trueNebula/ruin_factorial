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
