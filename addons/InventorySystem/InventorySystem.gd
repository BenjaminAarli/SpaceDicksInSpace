@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("InventoryGrid", "ColorRect", load("../nodes/InventoryGrid.gd"), load("../graphics/grid_empty.png"))
	add_custom_type("InventoryItem", "TextureRect", load("../nodes/InventoryItem.gd"), load("../graphics/grid_empty.png"))
	add_custom_type("InventorySlot", "TextureRect", load("../nodes/InventorySlot.gd"), load("../graphics/grid_empty.png"))
	pass

func _exit_tree() -> void:
	remove_custom_type("InventoryGrid")
	remove_custom_type("InventoryItem")
	remove_custom_type("InventorySlot")
	pass
