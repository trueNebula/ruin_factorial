package texture

import "src:core"

MAIN_FONT_SPACING :: 1
BOLD_FONT_SPACING :: 16
MONO_FONT_SPACING :: 8

InventorySlotCountStyle :: core.TextStyle {
	font        = .MAIN,
	size        = 8,
	spacing     = MAIN_FONT_SPACING,
	line_height = 10,
}
