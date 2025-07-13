extends Node3D
class_name Prop_SS_Door

@onready var area_open	: Area3D = %Area3D_Open
@onready var anim		: AnimationPlayer = $Size/Door/AnimationPlayer
@onready var timer: Timer = %Autoclose

@export var connections : Prop_SS_Door

var inside = []
var is_open = false

var locked = false

func _ready() -> void: 
	area_open.body_entered.connect(func(body): 
		if body.is_in_group("Player"): inside.append(body))
	area_open.body_exited.connect(func(body): 
		if body.is_in_group("Player"): inside.remove_at(inside.find(body)))
	area_open.body_entered.connect(check_inside)
	area_open.body_exited.connect(check_inside)
	timer.timeout.connect(func(): close())
	pass

func check_inside(_ignore):
	if can_close(): timer.start(2)
	else: open()
	pass

func open():
	if locked: return
	reset_timer()
	if is_open: return
	is_open = true
	anim.play("Open")
	if connections != null: connections.open()
	pass
	
func close():
	if !is_open: return
	is_open = false
	anim.play_backwards("Open")
	if connections != null: connections.close()
	pass

func can_close():
	var result = true
	if !inside.is_empty():
		result = false
	elif connections != null:
		if !connections.inside.is_empty():
			result = false
	return result

func reset_timer():
	timer.stop()
	if connections != null: connections.timer.stop()
	pass
