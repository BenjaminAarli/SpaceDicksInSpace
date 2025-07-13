extends FPSScene

@onready var ray = %RayCast3D

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventAction:
		if Input.is_action_just_pressed("Interact"):
			if not ray.is_colliding(): return
			var col = ray.get_collider()
			if col.is_in_group("MachinePlanter"):
				col.ui_open_close()
	pass
