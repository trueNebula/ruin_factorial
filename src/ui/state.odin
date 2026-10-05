package ui

import "hotbar"

State :: union {
	hotbar.HotbarState,
}

StateMap :: map[ComponentId]State
