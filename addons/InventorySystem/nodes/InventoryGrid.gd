@tool
extends ColorRect
class_name InventoryGrid

signal item_moved(item)
signal item_moved_failure(item)
signal items_updated(list)
signal items_cleared

signal items_emptied
signal item_moved_to_another_grid

const shader = preload("../graphics/fuck.gdshader")
const image  = preload("../graphics/grid_empty.png")

@export_tool_button("Sort Items") var btn_sort = sort_items
@export var remove_only : bool = false
@export var grid_size 			: Vector2i = Vector2i(5, 5) : 
	set(value): 
		grid_size = value
		update_grid_colormap([])
@export var quick_move_target 	: InventoryGrid	= null

var mouse_inside = false
var items : Array[InventoryItemData] = []: 
	set(value): 
		items = value
		update_grid()
		pass
 
func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("node_size", size)
	material.set_shader_parameter("grid_size", grid_size)
	material.set_shader_parameter("texture_albedo", image)
	update_grid_colormap()
	mouse_entered.connect(func(): 
		mouse_inside = true
	)
	mouse_exited.connect(func(): 
		mouse_inside = false
		update_grid_colormap()
	)
	item_moved_to_another_grid.connect(func():
		if items.size() == 0: items_emptied.emit()
		pass)
	update_grid()
	sort_items()
	pass

## Adds the InventoryItemData to the items array. 
@rpc("any_peer", "reliable", "call_local")
func add_item(data: InventoryItemData, pos := Vector2i.ZERO) -> void:
	if pos != null and can_insert_at(data, pos):
		print("Could be inserted at: ", pos, "Because it's not in here: ", get_used_slots())
		add_item_at.rpc(data, pos)
	elif can_auto_insert(data):
		auto_insert_item.rpc(data)
	else: # Could not place item into grid.
		pass
	pass

func remove_item(item: InventoryItemData):
	if items.has(item):
		items.remove_at(items.find(item))
	update_grid()
	pass

## Checks the position given (plus all slots the item would cover from that position) are available. 
func can_insert_at(item: InventoryItemData, pos: Vector2i) -> bool:
	var used = get_used_slots(item)
	var result = true
	if item.grid_size.x > grid_size.x:
		result = false
		print("CanInsert Result False on X")
	if item.grid_size.y > grid_size.y:
		result = false
		print("CanInsert Result False on Y")
	for x in item.grid_size.x:
		if result == false: break
		for y in item.grid_size.y:
			var itm_tile = pos + Vector2i(x, y)
			if used.has(itm_tile):
				result = false
				break
			if itm_tile.x >= grid_size.x or itm_tile.y >= grid_size.y or itm_tile.x < 0 or itm_tile.y < 0:
				result = false
				break
	return result

## Checks if there is an available space for the item to be put into
func can_auto_insert(item: InventoryItemData) -> bool:
	var result = false
	for x in grid_size.x:
		if result == true: break
		for y in grid_size.y:
			if can_insert_at(item, Vector2i(x, y)):
				result = true
				break
	return result

## Returns the Vector2i's of all slots used by an item. 
func get_used_slots(ignore: InventoryItemData = null) -> Array[Vector2i]:
	var slots_used : Array[Vector2i] = []
	for item: InventoryItemData in items:
		if ignore != null and item == ignore: continue
		for spot in item.get_slots_used():
			if not slots_used.has(spot): slots_used.append(spot)
	return slots_used

@rpc("any_peer", "reliable", "call_local")
func add_item_at(item: InventoryItemData, pos: Vector2i):
	print("Add item: ", item, " \n at position: ", pos)
	item.grid_position = pos
	items.append(item)
	update_grid()
	pass

## Sets a full list of InventoryItemData as the items of this grid.
func set_items(items: Array[InventoryItemData]) -> void:
	self.items = items
	pass

# TODO: Sort Items in Inventory Grid. 
func sort_items():
	update_grid()
	pass

## Check for if InventoryItemData exists in items.
func has_item(data: InventoryItemData) -> bool:
	return items.has(data)

## Inserts an item at the first spot that fits it from top_left. 
func auto_insert_item(item: InventoryItemData):
	print("Auto Inserted Item")
	var found_pos = false
	var pos = Vector2i(-1, -1)
	for x in range(grid_size.x):
		if found_pos == true: break
		for y in range(grid_size.y): 
			if can_insert_at(item, Vector2i(x, y)):
				pos = Vector2i(x, y)
				found_pos = true
				break
	if found_pos: add_item_at.rpc(item, pos)
	pass

## Moves an item to the new grid position on the same grid.
func move_item(item: InventoryItem, grid_pos: Vector2i) -> void:
	item.moved_item.emit(item.data.grid_position, grid_pos)
	var i_old_pos = item.data.grid_position
	if can_insert_at(item.data, grid_pos):
		item.data.grid_position = grid_pos
	update_grid()
	pass

@rpc("any_peer", "reliable", "call_local")
func clear_items():
	for c in get_children(): 
		c.queue_free()
	items_cleared.emit()
	pass

## Moves an item from one grid to another using auto_insert_item()
func quick_move(item: InventoryItemData):
	#quick_move_target.auto_insert_item(item)
	pass

## Returns the amount of used slots of this grid. 
func get_used_slots_amount(ignore: InventoryItemData = null) -> int:
	var slots_used: int = 0
	for item: InventoryItemData in items:
		if ignore != null and item == ignore: continue
		slots_used += item.get_slot_amount_used()
	return slots_used

## Returns the slots used if you drop the currently held item where your mouse is. 
func get_used_slots_hovering(item: InventoryItem) -> Array[Vector2i]:
	if not mouse_inside: return [] as Array[Vector2i]
	var result : Array[Vector2i] = []
	var gridpos = local_to_grid_position(get_local_mouse_position())
	if item != null: gridpos -= item.get_held_pos_to_grid()
	result.append(gridpos)
	if item != null:
		for x in item.data.grid_size.x:
			for y in item.data.grid_size.y:
				result.append(gridpos + Vector2i(x, y))
	return result

## Returns the amount of available slots of this grid. 
func get_available_slots_amount(ignore: InventoryItemData = null)  -> int:
	return get_slots_amount() - get_used_slots_amount(ignore)

## Returns the amount of slots in this grid. 
func get_slots_amount() -> int:
	return (grid_size.x * grid_size.y)

## Places all items on the grid correctly and makes sure their widths and heights are correct. 
func update_grid():
	clear_items()
	await items_cleared
	var i = 0
	for item: InventoryItemData in items:
		var node = InventoryItem.new(item)
		node.position 	= Vector2((size.x / grid_size.x) * item.grid_position.x, (size.y / grid_size.y) * item.grid_position.y)
		node.size 		= Vector2((size.x / grid_size.x) * item.grid_size.x, 	 (size.y / grid_size.y) * item.grid_size.y)
		
		node.data.grid_position.x = clampi(node.data.grid_position.x, 0, grid_size.x)
		node.data.grid_position.y = clampi(node.data.grid_position.y, 0, grid_size.y)
		
		add_child(node)
		i += 1
	pass

## Returns the grid position using local mouse position. 
func local_to_grid_position(pos: Vector2) -> Vector2i:
	return Vector2i( Vector2(pos) / ( Vector2(size) / Vector2(grid_size) ))

## Retuns the local mouse position of the given grid position. Can be centered.
func grid_to_local_position(gridpos: Vector2i, centered := false) -> Vector2:
	var result = Vector2(gridpos) * ( size / Vector2(grid_size) )
	if centered: result += Vector2( (size / Vector2(grid_size)) / 2 )
	return result

## Returns the size of a single grid square. 
func get_grid_square_size() -> Vector2:
	return size / Vector2(grid_size)

## Updates the colors behind. Used when holding an item to show where you are dropping it. 
func update_grid_colormap(used_grid_slots = []):
	material.set_shader_parameter("node_size", size)
	material.set_shader_parameter("grid_size", grid_size)
	var grid_image = Image.create(grid_size.x, grid_size.y, false, Image.FORMAT_RGBA8)
	for pos in used_grid_slots:
		if pos.x < 0 or pos.y < 0: continue
		if pos.x >= grid_size.x or pos.y >= grid_size.y: continue
		grid_image.set_pixel(pos.x, pos.y, Color.FIREBRICK)
	material.set_shader_parameter("grid_color", ImageTexture.create_from_image(grid_image))
	pass

### Detach Signals to item.
#func detatch_signals(item: InventoryItem):
	#if item.on_release.is_connected(update_grid): item.on_release.disconnect(update_grid)
	#if item.quick_move.is_connected(quick_move): item.quick_move.disconnect(quick_move)
	#if item.on_release_failure.is_connected(item_fn_release_failure): item.on_release_failure.disconnect(item_fn_release_failure)	
	#pass
#
### Attach Signals to item.
#func attach_signals(item: InventoryItem):
	#item.on_release.connect(update_grid)
	#item.on_release_failure.connect(item_fn_release_failure.bind(item))
	## item.on_release.connect(item_fn_release.bind(item))
	#item.quick_move.connect(quick_move.bind(item)) 
	#pass

# --------------------------------- #

func reset() -> void:
	print("GRID: Reset()")
	pass

## Simple function made just so I can have this code somewhere. 
func _new_item_added():
	var place_here = local_to_grid_position(get_local_mouse_position()) - Vector2i(InventoryItem.held_item.get_held_pos_to_grid())
	var data = InventoryItem.held_item.data
	add_item.rpc(data, place_here)
	var gr : InventoryGrid = InventoryItem.held_item.get_parent()
	gr.remove_item(InventoryItem.held_item.data)
	gr.item_moved_to_another_grid.emit()
	InventoryItem.held_item = null
	pass

## Simple function made just so I can have this code somewhere. 
func _item_moved():
	var place_here = local_to_grid_position(get_local_mouse_position()) - Vector2i(InventoryItem.held_item.get_held_pos_to_grid())
	move_item.rpc(InventoryItem.held_item, place_here)
	pass

func _input(event: InputEvent) -> void:
	if mouse_inside:
		if event is InputEventMouseMotion:
			if mouse_inside and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and InventoryItem.held_item != null:
				update_grid_colormap(get_used_slots_hovering(InventoryItem.held_item))
		if event is InputEventMouseButton:
			# Item released on grid. 
			if mouse_inside and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): # on left mouse button released.
				if InventoryItem.held_item != null:
					if has_item(InventoryItem.held_item.data):
						_item_moved()
					else: 
						if remove_only: return
						_new_item_added()
				pass

## Item was returned to the grid after failed setting elsewhere. 
func item_fn_release_failure(item: InventoryItem):
	print("GRID-ITEM: Item was returned to InvenGrid")
	update_grid()
	pass
