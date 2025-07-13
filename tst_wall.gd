extends Node3D

var stage 		= 1
const stages		= {
	1: 		"Wall_full",
	0.5: 	"wall_half",
	0.25:   	"wall_empty"
}

var health 		= 10.0
var health_max 	= 10.0

func _ready() -> void:
	for mesh in $wall_damage_test.get_children(): 
		if mesh.name == stages[stage]: mesh.show()
		else: mesh.hide()

func check_wall_state():
	var percent: float = (health / health_max)
	for c_stage in stages:
		if percent == c_stage:
			print(c_stage, " : ", percent)
			continue
		if percent <= c_stage:
			print(c_stage, " : ", percent)
			stage = c_stage
			# Show Wall, hide other walls. 
			for mesh in $wall_damage_test.get_children(): 
				if mesh.name == stages[stage]: mesh.show()
				else: mesh.hide()
			pass
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("dev_check_wall"):
			check_wall_state()
		if Input.is_action_just_pressed("dev_hurt_wall"):
			health -= 1
			print("health is now: ", health)
		pass
		
