extends Area3D


var inside: Array = []

func _ready() -> void:
	body_entered.connect(func(body):
		if body.is_in_group("Effected_By_Gravity_Change"):
			if not inside.has(body): inside.append(body)
			print("Airlock Person Added")
		pass)
	body_exited.connect(func(body):
		if body.is_in_group("Effected_By_Gravity_Change"):
			if inside.has(body): inside.remove_at(inside.find(body))
			print("Airlock Person Removed")
		pass)

func player_set_gravity(space_state: bool):
	for asdf in inside:
		if asdf is PlayerBody:
			asdf = asdf as PlayerBody
			asdf.in_space = space_state
		if asdf is PropTool:
			if asdf.gravity_scale >= 1:
				asdf.gravity_scale = 0
			elif asdf.gravity_scale == 0:
				asdf.gravity_scale = 1
				pass
	pass
