package engine

import "src:core"
import "src:ecs"
import "src:log"
import rl "vendor:raylib"

DebugHandleClickedEntity :: proc(engine: ^Engine, camera: rl.Camera2D) {
	if .LEFT not_in engine.frameInput.mousePressed do return

	engine.selectedEntity = 0
	mousePos := rl.GetScreenToWorld2D(engine.frameInput.mousePos, camera)
	view := ecs.View2(engine.world, core.Transform, core.Sprite)

	for entity in view {
		transform := entity.c1
		sprite := entity.c2
		visualPos := core.AnchorPosition(
			{transform.x, transform.y},
			core.GetSize(sprite.rect),
			sprite.anchor,
		)
		rect := core.MakeRect(visualPos, core.GetSize(sprite.rect))

		if rl.CheckCollisionPointRec(mousePos, rect) {
			engine.selectedEntity = entity.id
			return
		}
	}
}
