extends Node

signal inventory_update(list)

var inventory: Array[InventoryItemData] = []: 
	set(value):
		inventory_update.emit(value)
		inventory = value
		pass
