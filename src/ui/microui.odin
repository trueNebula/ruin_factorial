package ui

import "core:fmt"
import "src:core"
import mu "vendor:microui"
import rl "vendor:raylib"

MuState :: struct {
	muCtx:        mu.Context,
	atlasTexture: rl.Texture2D,
}

@(private = "file")
state: MuState
@(private = "file")
pixels: [][4]u8

InitMu :: proc() {
	pixels = make([][4]u8, mu.DEFAULT_ATLAS_WIDTH * mu.DEFAULT_ATLAS_HEIGHT)
	for alpha, i in mu.default_atlas_alpha {
		pixels[i] = {0xff, 0xff, 0xff, alpha}
	}
	defer delete(pixels)

	image := rl.Image {
		data    = raw_data(pixels),
		width   = mu.DEFAULT_ATLAS_WIDTH,
		height  = mu.DEFAULT_ATLAS_HEIGHT,
		mipmaps = 1,
		format  = .UNCOMPRESSED_R8G8B8A8,
	}

	ctx := &state.muCtx
	mu.init(ctx)
	ctx.text_width = mu.default_atlas_text_width
	ctx.text_height = mu.default_atlas_text_height
	state.atlasTexture = rl.LoadTextureFromImage(image)
}

FrameMu :: proc() {
	update()
	debug()
	end()
}

ShutdownMu :: proc() {
	rl.UnloadTexture(state.atlasTexture)
}

@(private = "file")
update :: proc() {
	ctx := &state.muCtx

	mouse_pos := [2]i32{rl.GetMouseX(), rl.GetMouseY()}
	mu.input_mouse_move(ctx, mouse_pos.x, mouse_pos.y)
	mu.input_scroll(ctx, 0, i32(rl.GetMouseWheelMove() * -30))

	@(static) buttons_to_key := [?]struct {
		rl_button: rl.MouseButton,
		mu_button: mu.Mouse,
	}{{.LEFT, .LEFT}, {.RIGHT, .RIGHT}, {.MIDDLE, .MIDDLE}}

	for button in buttons_to_key {
		if rl.IsMouseButtonPressed(button.rl_button) {
			mu.input_mouse_down(ctx, mouse_pos.x, mouse_pos.y, button.mu_button)
		} else if rl.IsMouseButtonReleased(button.rl_button) {
			mu.input_mouse_up(ctx, mouse_pos.x, mouse_pos.y, button.mu_button)
		}
	}
	mu.begin(ctx)
	rl.BeginScissorMode(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight())
}

@(private = "file")
end :: proc() {
	ctx := &state.muCtx
	mu.end(ctx)
	render(ctx)
	rl.EndScissorMode()
}

@(private = "file")
debug :: proc() {
	@(static) opts := mu.Options{.NO_CLOSE}
	ctx := &state.muCtx

	if (mu.window(ctx, "Debug Menu", {0, rl.GetScreenHeight() - 450, 300, 450}, opts)) {
		window := mu.get_current_container(ctx)
		mu.layout_row(ctx, {300}, 0)
		mu.label(ctx, fmt.tprint("FPS:", rl.GetFPS()))
		mu.label(ctx, fmt.tprintf("Frametime: %3f", rl.GetFrameTime() * 1000))

		mu.checkbox(ctx, "Draw Screen Bounds", &core.DEBUG.drawScreenBounds)
		mu.checkbox(ctx, "Draw Chunk Bounds", &core.DEBUG.drawChunkBounds)
		mu.checkbox(ctx, "Draw Chunk Generation Bounds", &core.DEBUG.drawChunkGenBounds)

		// mu.checkbox(ctx, "God Mode", &u.DEBUG_OPTS.GOD_MODE);
		// mu.checkbox(ctx, "Draw Colliders", &u.DEBUG_OPTS.SHOW_COLLIDERS);
		// mu.checkbox(ctx, "Draw Chunk Borders", &u.DEBUG_OPTS.SHOW_CHUNK_BORDERS);
		// mu.checkbox(ctx, "Draw Base Layer", &u.DEBUG_OPTS.RENDER_LAYER_BASE);
		// mu.checkbox(ctx, "Draw Top Layer", &u.DEBUG_OPTS.RENDER_LAYER_TOP);
		// mu.checkbox(ctx, "Draw Decals Layer", &u.DEBUG_OPTS.RENDER_LAYER_DECALS);
		// mu.checkbox(ctx, "Draw Objects Layer", &u.DEBUG_OPTS.RENDER_LAYER_OBJECTS);

		// mu.checkbox(ctx, "Do player collision", &u.DEBUG_OPTS.DO_PLAYER_COLLISION);
		// mu.label(ctx, "Player speed multiplier");
		// mu.slider(ctx, &u.DEBUG_OPTS.PLAYER_SPEED_MULTIPLIER, 1, 10, 0.5);
		mu.label(ctx, "Camera zoom")
		mu.slider(ctx, &core.DEBUG.zoom, -6, 3, 1)
	}
}

@(private = "file")
render :: proc(ctx: ^mu.Context) {
	renderTexture :: proc(rect: mu.Rect, pos: [2]i32, color: mu.Color) {
		source := rl.Rectangle{f32(rect.x), f32(rect.y), f32(rect.w), f32(rect.h)}
		position := rl.Vector2{f32(pos.x), f32(pos.y)}

		rl.DrawTextureRec(state.atlasTexture, source, position, transmute(rl.Color)(color))
	}

	commandBacking: ^mu.Command

	for variant in mu.next_command_iterator(ctx, &commandBacking) {
		switch cmd in variant {
		case ^mu.Command_Text:
			pos := [2]i32{cmd.pos.x, cmd.pos.y}
			for char in cmd.str do if char & 0xc0 != 0x80 {
				r := min(int(char), 127)
				rect := mu.default_atlas[mu.DEFAULT_ATLAS_FONT + r]
				renderTexture(rect, pos, cmd.color)
				pos.x += rect.w
			}
		case ^mu.Command_Rect:
			rl.DrawRectangle(
				cmd.rect.x,
				cmd.rect.y,
				cmd.rect.w,
				cmd.rect.h,
				transmute(rl.Color)(cmd.color),
			)
		case ^mu.Command_Icon:
			rect := mu.default_atlas[cmd.id]
			x := cmd.rect.x + (cmd.rect.w - rect.w) / 2
			y := cmd.rect.y + (cmd.rect.h - rect.h) / 2
			renderTexture(rect, {x, y}, cmd.color)
		case ^mu.Command_Clip:
			rl.EndScissorMode()
			rl.BeginScissorMode(cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h)
		case ^mu.Command_Jump:
			unreachable()
		}
	}
}
