package core

WindowDefaults: WindowProps = {
	width     = 1280,
	height    = 720,
	title     = "Ruin! Factorial - v0.0.0.1",
	minWidth  = 640,
	minHeight = 360,
}

DefaultKeybinds :: Keybinds {
	Up        = .W,
	Down      = .S,
	Left      = .A,
	Right     = .D,
	Action    = .LEFT,
	Interact  = .RIGHT,
	Inventory = .ESCAPE,
}
