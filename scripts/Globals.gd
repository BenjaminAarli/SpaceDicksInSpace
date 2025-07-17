extends Node

const groups = {
	player = "Players",
}

const scn_pausemenu = preload("res://scn_pausemenu.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("Pause"):
			if get_tree().get_nodes_in_group("PauseMenu").size() > 0: 
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				for n in get_tree().get_nodes_in_group("PauseMenu"):
					n.queue_free()
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				var n = scn_pausemenu.instantiate()
				n.add_to_group("PauseMenu")
				add_child(n)
	pass
