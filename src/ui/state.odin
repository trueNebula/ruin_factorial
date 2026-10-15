package ui

import "components"

State :: union {
	components.HotbarState,
}

StateMap :: map[ComponentId]State
