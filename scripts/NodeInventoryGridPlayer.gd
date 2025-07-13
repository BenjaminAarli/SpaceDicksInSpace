@tool
extends InventoryGrid
class_name InventoryGridPlayer

func _ready() -> void:
	super()
	visibility_changed.connect(func():
		items = PlayerData.inventory
		pass)
	PlayerData.inventory_update.connect(func(list):
		items = list
		pass)
	items_updated.connect(func(list): 
		PlayerData.inventory = list
		pass)
	pass
