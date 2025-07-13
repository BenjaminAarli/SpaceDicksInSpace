extends Node3D

@onready var area = %Area3D
@onready var area_oxygen = %SpaceCloset_01
@onready var mesh_status = %mesh_status
@onready var label_status  = %label_status 

@export var doors_ship : Array[DoorAction]
@export var doors_space: Array[DoorAction]

var inside: Array[PlayerBody] = []

enum STATE {OXYGEN, NO_OXYGEN, SWAPPING}
var state: STATE = STATE.OXYGEN

func _ready() -> void:
	%Timer.one_shot = true
	state_changed.rpc(state)
	area.body_entered.connect(func(body): 
		if body.is_in_group("Player"):
			inside.append(body)
			body = body as PlayerBody
			body.player_action.connect(interact)
	)
	area.body_exited.connect(func(body): 
		if body.is_in_group("Player"):
			inside.remove_at(inside.find(body))
			body.player_action.disconnect(interact)
	)
	%Timer.timeout.connect(func():
		print("Timer Timed out.")
	)
	for door in doors_ship:  door.lock.rpc()
	for door in doors_space: door.lock.rpc()
	pass

@rpc("any_peer", "call_local", "reliable")
func interact(p):
	state_changed.rpc(STATE.SWAPPING)
	%Timer.start(2)
	await %Timer.timeout
	print("First Timer Timeout")
	if state == STATE.NO_OXYGEN: # Swaps to Ground-Mode
		%GravityZone.player_set_gravity(false)
		%CPUParticle_Air.emitting = true
	elif state == STATE.OXYGEN: # Swaps to Space-Mode
		%GravityZone.player_set_gravity(true)
		%CPUParticle_Space.emitting = true
	%Timer.start(2)
	await %Timer.timeout
	print("Second Timer Timeout")
	if state == STATE.NO_OXYGEN: # Swaps to Ground-Mode
		state = STATE.OXYGEN
		state_changed.rpc(state)
	elif state == STATE.OXYGEN: # Swaps to Space-Mode
		state = STATE.NO_OXYGEN
		state_changed.rpc(state)
		%GravityZone.player_set_gravity(true)
	pass

var c_door = 0
@rpc("any_peer", "call_local", "reliable")
func state_changed(new_state: STATE):
	match new_state:
		STATE.OXYGEN:
			print("STATE: Oxygenated.")
			label_status.text   = "OXYGENATED"
			%label_status2.text = "OXYGENATED"
			%label_status3.text = "OXYGENATED"
			for door in doors_ship:
				door.open_forced.rpc()
				pass
			for door in doors_space:
				door.close_forced.rpc()
				pass
		STATE.NO_OXYGEN:
			print("STATE: Non - Oxygenated.")
			label_status.text   = "ZERO OXYGEN"
			%label_status2.text =  "ZERO OXYGEN"
			%label_status3.text =  "ZERO OXYGEN"
			for door in doors_ship:
				door.close_forced.rpc()
				pass
			for door in doors_space:
				door.open_forced.rpc()
				pass
		STATE.SWAPPING:
			print("STATE: Swapping.")
			label_status.text   = "SWAPPING..."
			%label_status2.text = "SWAPPING..."
			%label_status3.text = "SWAPPING..."
			for door in doors_ship:
				door.close_forced.rpc()
				pass
			for door in doors_space:
				door.close_forced.rpc()
				pass
	pass
