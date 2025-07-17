extends Node3D

@onready var node_players 	= %Players
@onready var node_spawns 	= %Spawns
@onready var scn_player = preload("res://Player.tscn")

var player_spawn_data = {}

func _ready() -> void:
	var spawns = []
	for s in node_spawns.get_children(): 
		spawns.append(s.global_position)
	randomize()
	var spawn = spawns.pick_random()
	spawn_self(multiplayer.get_unique_id(), spawn)
	multiplayer.connected_to_server.connect(func(id):
		send_spawn.rpc(id, spawn)
		print("1 - Sent Spawn: ", id, " at ", spawn)
	)
	multiplayer.peer_connected.connect(func(id): 
		spawn_player.rpc(id)
		print("2 - Spawned: ", id)
	)
	multiplayer.server_disconnected.connect(func():
		get_tree().change_scene_to_file("res://scenes/scn_lobby.tscn")
		pass)
	pass

func spawn_self(id, spawn):
	spawn_player.rpc(id, spawn)
	pass

@rpc("any_peer", "call_remote", "reliable")
func send_spawn(id: int, spawn: Vector3):
	player_spawn_data[id] = spawn
	node_players.get_node(str(id)).global_position = spawn
	print("Player Spawn data added: ", id, " | ", spawn)
	pass

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id: int, _spawn: Vector3 = Vector3.ZERO):
	var plr: PlayerBody = scn_player.instantiate()
	plr.name = str(id)
	plr.set_multiplayer_authority(id)
	print("PlayerSpawnData[]: ", str(player_spawn_data))
	if player_spawn_data.has(id):
		plr.global_position = player_spawn_data[id]
		print("spawned player using player_spawn_data")
	if Network.disconnected_players_positions.has(id):
		plr.global_position = Network.disconnected_players_positions[id]
		print("spawned player using diconnected_player_position")
	else: 
		plr.global_position = _spawn
		print("spawned player using _spawn")	
	node_players.add_child(plr)
	pass
