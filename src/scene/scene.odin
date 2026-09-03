package scene

import "src:ecs"
import "src:event"
import "src:neb_utils"
import "src:render"
import "src:texture"
import "src:tilemap"
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
FAST_DURATION: f32 : 1.0 // Seconds

Transition :: struct {
	state:     TransitionState,
	timer:     f32,
	duration:  f32,
	nextScene: SceneId,
}

SceneManager :: struct {
	current:        SceneId,
	transition:     Transition,
	data:           Scene,
	// Context pointers
	textureManager: ^texture.TextureManager,
	world:          ^ecs.World,
	queue:          ^event.Queue,
}

MakeSceneManger :: proc(
	texMan: ^texture.TextureManager,
	world: ^ecs.World,
	queue: ^event.Queue,
) -> SceneManager {
	sceneMan := SceneManager {
		current = .MENU,
		transition = Transition {
			state = .FADE_IN,
			timer = 0.0,
			duration = FAST_DURATION,
			nextScene = .MENU,
		},
		textureManager = texMan,
		world = world,
		queue = queue,
	}
	return sceneMan
}

LoadFirstScene :: proc(sceneMan: ^SceneManager) {
	loadMenuScene(sceneMan)
}

LoadScene :: proc(sceneMan: ^SceneManager, id: SceneId) {
	switch id {
	case .MENU:
		loadMenuScene(sceneMan)
	case .GAME:
		loadGameScene(sceneMan)
	}
}

@(private)
triggerSceneTransition :: proc(sceneMan: ^SceneManager, target: SceneId) {
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
initNextScene :: proc(sceneMan: ^SceneManager) {
	switch sceneMan.transition.nextScene {
	case .MENU:
		sceneMan.data = initMenuScene(sceneMan)
	case .GAME:
		sceneMan.data = initGameScene(sceneMan)
	}
}

@(private)
unloadScene :: proc(sceneMan: ^SceneManager) {
	switch sceneMan.current {
	case .MENU:
		unloadMenuScene(sceneMan)
	case .GAME:
		unloadGameScene(sceneMan)
	}
}

ShouldBlockInput :: proc(sceneMan: ^SceneManager) -> bool {
	if sceneMan.transition.state != .NONE {
		return true
	}
	return false
}

Update :: proc(sceneMan: ^SceneManager) {
	dt := rl.GetFrameTime()

	transition := &sceneMan.transition
	switch transition.state {
	case .NONE:
	case .FADE_OUT:
		transition.timer += dt
		if transition.timer >= transition.duration {
			unloadScene(sceneMan)
			sceneMan.current = transition.nextScene
			initNextScene(sceneMan)
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

DrawTransition :: proc(sceneMan: ^SceneManager) {
	dt := rl.GetFrameTime()
	transition := &sceneMan.transition

	switch transition.state {
	case .NONE:
	case .FADE_OUT:
		alpha := neb_utils.OpacityLerp(0, 255, transition.timer / transition.duration)
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), {0, 0, 0, alpha})
		rl.DrawText(
			"Loading...",
			rl.GetScreenWidth() / 2,
			rl.GetScreenHeight() / 2,
			24,
			{255, 255, 255, alpha},
		)
	case .FADE_IN:
		alpha := neb_utils.OpacityLerp(255, 0, transition.timer / transition.duration)
		rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), {0, 0, 0, alpha})
		rl.DrawText(
			"Loading...",
			rl.GetScreenWidth() / 2,
			rl.GetScreenHeight() / 2,
			24,
			{255, 255, 255, alpha},
		)
	}
}
