package engine

import "src:core"
import "src:ecs"
import "src:player"
import "src:scene"
import "src:ui/components"

@(private)
buildMenuUi :: proc(engine: ^Engine) {
	switch components.MainMenu(engine.uiManager) {
	case .START:
		resetRng(engine, nil)
		scene.LoadScene(engine.sceneManager, .GAME)
	case .START_SEEDED:
		resetRng(engine, 6283573998654693917)
		scene.LoadScene(engine.sceneManager, .GAME)
	case .SETTINGS:
	case .EXIT:
	case .NONE:
	}
}

@(private)
buildGameUi :: proc(engine: ^Engine) {
	inventory, invErr := player.GetPlayerComponent(
		engine.world,
		player.MAIN_PLAYER_REF,
		core.Inventory,
	)
	mouseItem, mouseErr := player.GetPlayerComponent(
		engine.world,
		player.MAIN_PLAYER_REF,
		core.MouseItem,
	)
	if invErr || mouseErr {
		return
	}
	switch engine.uiManager.menu.ui {
	case .NONE:
		slots := inventory.slots[0:10]
		components.Hotbar(engine.uiManager, engine.repo, {slots = slots})
	case .INVENTORY:
		clickedSlotIdx, mouseButton := components.Inventory(
			engine.uiManager,
			engine.repo,
			engine.textureManager,
			{slots = inventory.slots[:]},
		)
		if idx, ok := clickedSlotIdx.?; ok {
			player.OnInventorySlotClicked(
				inventory,
				idx,
				mouseItem,
				mouseButton.(core.MouseButton) == .RIGHT,
			)
		}
	case .STORAGE:
		storageInput, storageErr := ecs.GetComponentForEntity(
			engine.world,
			engine.uiManager.menu.entity,
			core.Inventory,
		)
		if storageErr do return
		clickedSlotInStorageIdx, mouseButtonInStorage := components.Storage(
			engine.uiManager,
			engine.repo,
			engine.textureManager,
			{slots = storageInput.slots[:]},
		)
		if idx, ok := clickedSlotInStorageIdx.?; ok {
			player.OnInventorySlotClicked(
				storageInput,
				idx,
				mouseItem,
				mouseButtonInStorage.(core.MouseButton) == .RIGHT,
			)
		}

		clickedSlotIdx, mouseButton := components.Inventory(
			engine.uiManager,
			engine.repo,
			engine.textureManager,
			{slots = inventory.slots[:]},
		)
		if idx, ok := clickedSlotIdx.?; ok {
			player.OnInventorySlotClicked(
				inventory,
				idx,
				mouseItem,
				mouseButton.(core.MouseButton) == .RIGHT,
			)
		}
	}
}
