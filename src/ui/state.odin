package ui

import "src:core"

State :: union {
	HotbarState,
}

HotbarState :: struct {
	selected: int,
}

GetState :: proc(uiMan: ^UiManager, $T: typeid, key: Id) -> (component: ^T, err: bool) {
	state, ok := &uiMan.state[key]

	if !ok {
		return nil, true
	}

	switch v in state {
	case HotbarState:
		return state.(HotbarState), false
	case InventoryState:
		return state.(InventoryState), false
	case:
		return nil, true
	}
}
