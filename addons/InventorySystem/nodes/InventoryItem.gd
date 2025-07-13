@tool
extends TextureRect
class_name InventoryItem

signal dropped_on_grid
signal dropped_on_slot
signal dropped_on_nothing

signal changed_owner(old, new)
signal moved_item(old_pos, new_pos)
signal check_can_move(result) # Unused

signal on_grab

signal on_release
signal on_release_failure
signal on_release_success

signal rotate
signal quick_move(item: InventoryItem)

const dev_image = preload("../graphics/no_texture.png")
const shader 	= preload("../graphics/item_overlay.gdshader")

## The current held item. 
static var held_item: InventoryItem = null
var is_held 				= false
var was_rotated 			= false
var was_dropped 			= true

@export var data := InventoryItemData.new()

var mouse_grab_point 	= Vector2.ZERO ## Position of mouse grab.. 
var mouse_inside 		= false

func _ready() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mouse_entered.connect(func(): mouse_inside = true)
	mouse_exited.connect( func(): mouse_inside = false)
	modulate.a = 1
	stretch_mode = TextureRect.STRETCH_SCALE
	if texture == null: 
		texture = dev_image
	material = ShaderMaterial.new() 
	material.shader = shader
	pass

func _init(data: InventoryItemData = null) -> void:
	if data != null: self.data = data
	pass

## Changes the image texture
func set_image(image: Texture2D) -> void:
	texture = image if image != null else dev_image
	pass

## Returns the grid position using the position you clicked on the item to grab it. 
func get_held_pos_to_grid() -> Vector2i: 
	return Vector2i(Vector2(mouse_grab_point) / ( Vector2(size) / Vector2(data.grid_size) )) 

## Returns the amount of slots this item uses. 
func get_slot_amount_used() -> int:
	var used: int = 0
	for x in data.grid_size.x:
		for y in data.grid_size.y: 
			used += 1
	return used

## When grabbing the item with the mouse. 
func grab_item() -> void:
	on_grab.emit()
	mouse_filter 	= Control.MOUSE_FILTER_IGNORE
	is_held 		= true
	modulate.a 		= 0.8
	held_item 		= self
	z_index 		= 1000
	was_dropped 	= false
	print("ITEM: I was grabbed")
	pass

## When no longer grabbing the item with the mouse. 
func release_item() -> void:
	on_release.emit()
	mouse_filter 	= Control.MOUSE_FILTER_STOP
	modulate.a 		= 1.0
	is_held 		= false
	z_index 		= 0
	held_item 		= null
	was_rotated 	= false
	was_dropped 	= true
	print("ITEM: I was released! " + str(self))
	pass

## Swaps the height for the width. 
## (Can only happen while grabbed)
func rotate_item() -> void:
	data.grid_size = Vector2i(data.grid_size.y, data.grid_size.x)
	size = Vector2(size.y, size.x)
	mouse_grab_point = Vector2(mouse_grab_point.y, mouse_grab_point.x)
	was_rotated = true
	rotate.emit()
	pass

func item_was_quick_moved() -> void:
	print("ITEM: InvenItem: Quickmove")
	quick_move.emit()
	pass

func item_was_grabbed() -> void:
	print("\n\nITEM: Item was Grabbed.")
	mouse_grab_point = get_local_mouse_position()
	grab_item()
	
	pass

func item_was_dropped() -> void:
	release_item()
	if get_parent() is InventoryGrid:
		get_parent().update_grid()
	if get_parent() is InventorySlot:
		print("ITEM: InvenSlot Parent Reset. ")
		var p: InventorySlot = get_parent()
		p.item_fn_release_failure()
	pass

func _process(delta: float) -> void:
	## Item moves with mouse when grabbed. 
	if is_held: 	global_position = get_global_mouse_position() - mouse_grab_point
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_key_pressed(KEY_R) and is_held:
			rotate_item()
	if event is InputEventMouseButton:
		if mouse_inside and Input.is_physical_key_pressed(KEY_CTRL) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			item_was_quick_moved()
		# On Pickup of item. 
		elif  mouse_inside and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			item_was_grabbed()
		# On Release of item. 
		if is_held and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			await get_tree().process_frame or dropped_on_grid or dropped_on_slot # Wait a frame to check if anything else uses the item. 
			if not was_dropped: 
				get_parent().reset()
				item_was_dropped()
	pass
