extends TextureRect
class_name InventorySlot

signal item_changed

const dev_texture = preload("../graphics/grid_empty.png")

var item: InventoryItem = null
var mouse_inside: bool = false

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mouse_entered.connect(func(): mouse_inside = true)
	mouse_exited.connect( func(): mouse_inside = false)
	texture = dev_texture
	modulate.a = 1
	pass

## Inserts an item into this slot using an item, dumbass.
## Took all your brain power to figure that one out. 
func insert_item(item: InventoryItem) -> void:
	self.item 	= item
	texture 		= item.texture if item.texture != null else dev_texture
	item.reparent(self)
	item.hide()
	item.changed_owner.connect(item_fn_change_owner)
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	modulate.a = 1
	pass

## Clears the current item from ourselves.
func clear() -> void:
	stretch_mode = TextureRect.STRETCH_TILE
	item.changed_owner.disconnect(item_fn_change_owner)
	item = null
	texture = dev_texture
	modulate.a = 1
	pass

## Signal Function for when the current item changes owner. 
func item_fn_change_owner(old, new) -> void:
	clear()
	pass

## Signal Function for when the current item is released over nothing (or just generally, I guess) 
func item_fn_release() -> void:
	item.hide()
	item.release_item()
	modulate.a = 1
	pass

func item_fn_release_failure():
	modulate.a = 1
	item.hide()
	pass

func reset() -> void:
	print("SLOT: Reset()")
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# On Item Grabbed. 
		if mouse_inside and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if item != null:
				item.show()
				item.grab_item()
			modulate.a = 0.8
		# On Item Released.
		if mouse_inside and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("HeldItem: " + str(InventoryItem.held_item))
			if InventoryItem.held_item != null and item == null:
				var itm : InventoryItem = InventoryItem.held_item
				print("Dropped item on InvenSlot.")
				insert_item(InventoryItem.held_item)
				itm.release_item()
	pass
