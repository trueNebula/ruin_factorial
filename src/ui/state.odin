package ui

import "src:core"

State :: union {
	HotbarState,
	TooltipState,
}

HotbarState :: struct {
	selected: int,
}

TooltipState :: struct {
	titleCache:    string,
	titleCacheKey: string,
	descCache:     string,
	descCacheKey:  string,
}

GetState :: proc(uiMan: ^UiManager, $T: typeid, key: Id) -> (component: ^T, err: bool) {
	state, ok := &uiMan.state[key]

	if !ok {
		return nil, true
	}

	switch v in state {
	case HotbarState:
		return &state.(HotbarState), false
	case TooltipState:
		return &state.(TooltipState), false
	case:
		return nil, true
	}
}
