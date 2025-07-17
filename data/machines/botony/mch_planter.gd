extends Node3D
class_name mch_Planter

signal growth_started
signal growth_tick
signal growth_finished

@onready var plantSprites 	= %Sprites
@onready var timer 			= %Timer
@onready var ui_node 		= %UINode

var inside: Array[PlayerBody] = []

@export var plant_seed: PlantData = load("res://data/resources/plants/Wheat.tres"):
	set(value):
		plant_seed = value
		set_plant_image()
		pass

@export var stage = -1:
	set(value):
		stage = value
		set_plant_image()
		pass

func _ready() -> void:
	ui_close()
	add_to_group("MachinePlanter")
	add_to_group("Interactable")
	
	%PlayerLeaveArea.body_entered.connect(func(body):
		if body.is_in_group("Player"):
			inside.append(body)
			body = body as PlayerBody
		)
	%PlayerLeaveArea.body_exited.connect(func(body):
		if body.is_in_group("Player"):
			ui_close()
			inside.remove_at(inside.find(body))
		)
	growth_finished.connect(func():
		var inv_item := InventoryItemData.new()
		inv_item.set_image(plant_seed.bundle_image)
		var grid: InventoryGrid = %InventoryGrid
		grid.add_item(inv_item)
		pass)
	if timer != null and plant_seed != null:
		timer.start(plant_seed.grow_time_per_tick)
		timer.timeout.connect(tick)
	pass

func interact(interactor: PlayerBody): 
	var r = ui_open_close()
	if r: interactor.in_menu = true
	else: interactor.in_menu = false

func tick():
	var max = plant_seed.images.size() - 1
	stage = clamp(stage + 1, 0, max)
	set_plant_image()
	if stage < max: timer.start(plant_seed.grow_time_per_tick); growth_tick.emit()
	else: growth_finished.emit()
	pass

func set_stage(_stage: int):
	stage = _stage
	pass

@rpc("any_peer", "call_local", "reliable")
func clear():
	plant_seed = null
	set_stage(-1)
	clear_plant_image()
	if timer != null: timer.stop()
	pass

func _on_inventory_grid_items_emptied() -> void:
	clear.rpc()
	pass

func clear_plant_image():
	if plantSprites == null: return
	for plant in plantSprites.get_children():
		plant.texture = null
	pass

func set_plant_image():
	if plant_seed == null: clear_plant_image(); return
	var max_size = plant_seed.images.size() - 1
	var seed_img = plant_seed.images[clamp(stage, 0, max_size)]
	if seed_img == null: return
	if plantSprites == null: return
	for plant in plantSprites.get_children():
		plant.offset = Vector2(-seed_img.get_width() / 2, 0)
		plant.texture = seed_img
	pass

# UI Openers and Closers.

func ui_open_close() -> bool:
	if %UINode.visible: ui_close(); return false
	else: 				ui_open(); 	return true

func ui_open():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%UINode.show()
	pass

func ui_close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%UINode.hide()
	pass
