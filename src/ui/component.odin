package ui

import "src:render"
import "src:texture"

ComponentProcs :: union {}

ComponentId :: enum {
	HOTBAR,
}

Component :: struct {
	update: proc(state: State),
	render: proc(state: State, renMan: render.RenderManager, texMan: texture.TextureManager),
}
