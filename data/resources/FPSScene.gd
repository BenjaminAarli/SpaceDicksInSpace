extends Node3D
class_name FPSScene 

signal anim_played(anim)

# Networking
var user_id = 0

# Aniamtion
@onready var anim_tree: AnimationTree = %AnimationTree
var playback: AnimationNodeStateMachinePlayback
var c_anim = "": 
	set(nanim):
		if c_anim == nanim: return
		c_anim = nanim
		play_me.rpc(multiplayer.get_unique_id(), c_anim)
		playback.travel(c_anim)
		anim_played.emit(c_anim)
		pass

func _ready() -> void:
	print("FPSScene _ready()")
	anim_tree.active = true
	playback = anim_tree.get("parameters/playback")
	if is_multiplayer_authority():
		c_anim = "FPS_On_Equip"

## For people holding items, not the person using the item.
@rpc("any_peer", "call_remote", "reliable")
func play_me(_id, c_anim): 
	if user_id == _id: 
		print("Play_Me Anim: ", _id, " - ", c_anim)
		playback.travel(c_anim)
	pass

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventKey or event is InputEventMouse:
			if Input.is_action_just_pressed("FPS_Item_Attack"):
				c_anim = "FPS_Attack_Start"
				return
			elif Input.is_action_pressed("FPS_Item_Attack"):
				c_anim = "FPS_Attack"
				return
			elif Input.is_action_just_released("FPS_Item_Attack"):
				#await anim_tree.animation_finished
				c_anim = "FPS_Attack_End"
				return
			
			if Input.is_key_label_pressed(KEY_W):
				c_anim = "FPS_Moving"
			elif Input.is_key_label_pressed(KEY_A):
				c_anim = "FPS_Moving"
			elif Input.is_key_label_pressed(KEY_D):
				c_anim = "FPS_Moving"
			elif Input.is_key_label_pressed(KEY_S):
				c_anim = "FPS_Moving"
			else: 
				c_anim = "FPS_Idle"
			pass
