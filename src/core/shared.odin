package core

import rl "vendor:raylib"

WindowDefaults: WindowProps = {
	width     = 1280,
	height    = 720,
	title     = "Ruin! Factorial - v0.0.0.1",
	minWidth  = 640,
	minHeight = 360,
}

WorldView :: rl.Vector2{480, 270}
UiView :: rl.Vector2{960, 540}

DefaultKeybinds :: Keybinds {
	Up        = .W,
	Down      = .S,
	Left      = .A,
	Right     = .D,
	Action    = .LEFT,
	Interact  = .RIGHT,
	Inventory = .E,
	Close     = .ESCAPE,
}

TileSize :: 16
ChunkLenght :: 64
ChunkSize :: ChunkLenght * ChunkLenght
