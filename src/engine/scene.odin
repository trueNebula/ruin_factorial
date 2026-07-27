package engine

import "core:math/linalg"
import "src:game_utils"
import "src:neb_utils"
import rl "vendor:raylib"

SceneId :: enum {
	MENU,
	GAME,
}

Scene :: union {
	MenuScene,
	GameScene,
}

TransitionState :: enum {
	NONE,
	FADE_IN,
	FADE_OUT,
}

BASE_DURATION: f32 : 1.0 // Seconds
FAST_DURATION: f32 : 0.2 // Seconds

Transition :: struct {
	state:     TransitionState,
	timer:     f32,
	duration:  f32,
	nextScene: SceneId,
}

SceneManager :: struct {
	current:    SceneId,
	transition: Transition,
	data:       Scene,
}

MakeSceneManger :: proc() -> SceneManager {
	sceneMan := SceneManager {
		current = .MENU,
		transition = Transition {
			state = .FADE_IN,
			timer = 0.0,
			duration = FAST_DURATION,
			nextScene = .MENU,
		},
	}

	return sceneMan
}

@(private)
triggerSceneTransition :: proc(engine: ^Engine, target: SceneId) {
	sceneMan := engine.sceneManager
	if sceneMan.transition.state != .NONE {
		return
	}

	sceneMan.transition = Transition {
		state     = .FADE_OUT,
		timer     = 0.0,
		duration  = BASE_DURATION,
		nextScene = target,
	}
}

@(private)
initNextScene :: proc(engine: ^Engine) {
	sceneMan := engine.sceneManager
	switch sceneMan.transition.nextScene {
	case .MENU:
		sceneMan.data = initMenuScene()
	case .GAME:
		sceneMan.data = initGameScene(engine)
	}
}

@(private)
unloadScene :: proc(engine: ^Engine) {
	sceneMan := engine.sceneManager
	switch sceneMan.current {
	case .MENU:
		unloadMenuScene(engine)
	case .GAME:
		unloadGameScene(engine)
	}
}

InputScene :: proc(engine: ^Engine) {
	sceneMan := engine.sceneManager
	if sceneMan.transition.state != .NONE {
		return
	}
	switch sceneMan.current {
	case .MENU:
		if rl.IsMouseButtonPressed(.LEFT) {
			loadGameScene(engine)
		}
	case .GAME:
		if rl.IsKeyPressed(.ENTER) {
			loadMenuScene(engine)
		}
	}
}

UpdateScene :: proc(engine: ^Engine) {
	sceneMan := engine.sceneManager
	dt := rl.GetFrameTime()

	switch sceneMan.current {
	case .MENU:
		updateMenuScene(engine)
	case .GAME:
		updateGameScene(engine)
	}

	transition := &sceneMan.transition
	switch transition.state {
	case .NONE:
	case .FADE_OUT:
		transition.timer += dt
		if transition.timer >= transition.duration {
			unloadScene(engine)
			sceneMan.current = transition.nextScene
			initNextScene(engine)
			transition.state = .FADE_IN
			transition.duration = FAST_DURATION
			transition.timer = 0.0
		}
	case .FADE_IN:
		transition.timer += dt
		if transition.timer >= transition.duration {
			transition.state = .NONE
			transition.timer = 0.0
		}
	}
}

DrawScene :: proc(engine: ^Engine) {
	sceneMan := engine.sceneManager
	dt := rl.GetFrameTime()

	rl.BeginDrawing()
	switch sceneMan.current {
	case .MENU:
		drawMenuScene(engine)
	case .GAME:
		drawGameScene(engine)
	}

	transition := &sceneMan.transition
	switch transition.state {
	case .NONE:
	case .FADE_OUT:
		alpha := neb_utils.OpacityLerp(0, 255, transition.timer / transition.duration)
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), {0, 0, 0, alpha})
	case .FADE_IN:
		alpha := neb_utils.OpacityLerp(255, 0, transition.timer / transition.duration)
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), {0, 0, 0, alpha})
	}

	rl.EndDrawing()
}
