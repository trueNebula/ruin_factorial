package scene

import "src:core"
import "src:texture"
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
initMenuScene :: proc(sceneMan: ^SceneManager) -> MenuScene {
	texMan := sceneMan.textureManager

	texture.LoadFont(texMan, core.Font.MAIN, "/PixeloidSans.ttf", texture.MAIN_FONT_SPACING)
	texture.LoadFont(texMan, core.Font.BOLD, "/PixeloidSans-Bold.ttf", texture.BOLD_FONT_SPACING)
	texture.LoadFont(texMan, core.Font.MONO, "/PixeloidMono.ttf", texture.MONO_FONT_SPACING)

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
