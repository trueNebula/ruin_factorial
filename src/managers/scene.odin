package managers

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
	manager := SceneManager {
		current = .MENU,
		transition = Transition {
			state = .FADE_IN,
			timer = 0.0,
			duration = FAST_DURATION,
			nextScene = .MENU,
		},
	}

	loadMenuScene(&manager)
	return manager
}

@(private)
triggerSceneTransition :: proc(manager: ^SceneManager, target: SceneId) {
	if manager.transition.state != .NONE {
		return
	}

	manager.transition = Transition {
		state     = .FADE_OUT,
		timer     = 0.0,
		duration  = BASE_DURATION,
		nextScene = target,
	}
}

@(private)
initNextScene :: proc(manager: ^SceneManager) {
	switch manager.transition.nextScene {
	case .MENU:
		manager.data = initMenuScene()
	case .GAME:
		manager.data = GameScene{}
	}
}

InputScene :: proc(manager: ^SceneManager) {
	if manager.transition.state != .NONE {
		return
	}
	switch manager.current {
	case .MENU:
		if rl.IsMouseButtonPressed(.LEFT) {
			loadGameScene(manager)
		}
	case .GAME:
		if rl.IsKeyPressed(.ENTER) {
			loadMenuScene(manager)
		}
	}
}

UpdateScene :: proc(manager: ^SceneManager) {
	dt := rl.GetFrameTime()

	switch manager.current {
	case .MENU:
		updateMenuScene(manager)
	case .GAME:

	}

	transition := &manager.transition
	switch transition.state {
	case .NONE:
	case .FADE_OUT:
		transition.timer += dt
		if transition.timer >= transition.duration {
			// unload
			manager.current = transition.nextScene
			initNextScene(manager)
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

DrawScene :: proc(manager: ^SceneManager) {
	dt := rl.GetFrameTime()

	rl.BeginDrawing()
	switch manager.current {
	case .MENU:
		drawMenuScene(manager)
	case .GAME:
		drawGameScene(manager)
	}

	transition := &manager.transition
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
