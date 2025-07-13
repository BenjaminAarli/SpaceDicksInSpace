extends Node3D

@onready var node_players 	= %Players
@onready var node_spawns 	= %Spawns

@onready var scn_player = preload("res://Player.tscn")

var spawns = []

func _ready() -> void:
	for s in node_spawns.get_children(): spawns.append(s.global_position)
	spawn_players()
	pass

@rpc("any_peer", "call_local", "reliable")
func spawn_players():
	var index = 0
	for id in Network.players:
		var plr: PlayerBody = scn_player.instantiate()
		plr.name 	= str(id)
		plr.set_multiplayer_authority(id)
		node_players.add_child(plr)
		plr.global_position = Vector3(2 * index, 0, 0)
		index += 1
	randomize()
	var spawn = spawns.pick_random()
	set_spawn.rpc(multiplayer.get_unique_id(), spawn)
	remove_spawn.rpc(spawn)
	print("\n\n\nEND END END\n\n\n")
	pass

@rpc("any_peer", "call_local", "reliable")
func remove_spawn(spwn):
	print("We are removing a spawn.")
	for s in spawns:
		if s == spwn: 
			spawns.remove_at(spawns.find(s))
			break
	pass

@rpc("any_peer", "call_local", "reliable") func set_spawn(id, spawn):
	print("We are setting a spawn: ", id)
	if node_players.has_node(str(id)):
		var p: PlayerBody = node_players.get_node(str(id))
		p.global_position = spawn
	pass
