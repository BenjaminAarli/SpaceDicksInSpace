extends Area3D
class_name DoorAction


@onready var collision 	= $StaticBody3D/CollisionShape3D
@onready var anim 		= $Door/AnimationPlayer

var inside = []
var locked = false

func _ready() -> void:
	body_entered.connect(func(body): 
		if body.is_in_group("Player"):
			var player: PlayerBody = body
			inside.append(player)
			player.player_action.connect(check_player_interaction)
		pass)
	body_exited.connect(func(body):
		if body.is_in_group("Player"):
			inside.remove_at(inside.find(body))
			body.player_action.disconnect(check_player_interaction)
		pass)
	pass

func check_player_interaction(player):
	if inside.has(player):
		open_close.rpc(is_open)
	pass

var is_open = false
@rpc("any_peer", "call_local", "reliable")
func open_close(state):
	# OPEN DOOR
	if not state and not locked: open.rpc()
	# CLOSE DOOR
	elif state  and not locked: close.rpc()

@rpc("any_peer", "call_local", "reliable")
func close():
	if is_open and not locked:
		is_open = false
		anim.play_backwards("Open")
		remove_collisions.rpc(is_open)
	pass

@rpc("any_peer", "call_local", "reliable")
func open():
	if not is_open and not locked:
		is_open = true
		anim.play("Open")
		remove_collisions.rpc(is_open)
	pass

@rpc("any_peer", "call_local", "reliable")
func open_forced():
	if not is_open:
		is_open = true
		anim.play("Open")
		remove_collisions.rpc(is_open)
	pass

@rpc("any_peer", "call_local", "reliable")
func close_forced():
	if is_open:
		is_open = false
		anim.play_backwards("Open")
		remove_collisions.rpc(is_open)
	pass

@rpc("any_peer", "call_local", "reliable")
func remove_collisions(disabled: bool):
	collision.disabled = disabled
	if disabled: 
		%Label3D.text = "DISABLE"
		%Label3D2.text = "DISABLE"
	else:
		%Label3D.text = "ENABLE"
		%Label3D2.text = "ENABLE"
	pass

@rpc("any_peer", "call_local", "reliable")
func lock():   locked = true
@rpc("any_peer", "call_local", "reliable")
func unlock(): locked = false
