extends Node

var names = [
	"Steve",
	"Carl",
	"Linda",
	"Kevin",
	"Bob",
	"Maria",
	"Gaberella",
	"Ompa loompa",
	"Fuck",
	"Ludwig",
	"Funsized",
	"Large Cock"
]

@onready var textlog: RichTextLabel = %Textlog

var client_names: Dictionary[int, String] = {}: 
	set(new_list):
		client_names = new_list
		%NameList.clear()
		for player_id in Network.players:
			var pname = client_names[player_id] if client_names.has(player_id) else str(player_id)
			%NameList.add_item(pname)
		pass

func write(text: String):
	textlog.append_text(text + "\n")
	pass

@rpc("any_peer", "call_local", "reliable")
func send_player_data(id: int) -> void:
	if not Network.players.has(id): Network.players.append(id)
	pass

@rpc("any_peer", "call_local", "reliable")
func remove_player_data(id: int) -> void:
	if Network.players.has(id): Network.players.remove_at(Network.players.find(id))
	pass

func _ready() -> void:
	var test: Dictionary[int, String] = {
		0: "penis",
		1: "aweful spirit",
		3: "fuck you",
		5: "asdasdf"
	}
	
	print("Testing test dictionary")
	for whatever in test.keys():
		var value = test[whatever]
		print(str(whatever), " : ", value)
	print("End of test.")
	
	#client_names[0] = "Penisface"
	#client_names[425] = "Steve"
	
	multiplayer.connected_to_server.connect(server_connect_success) # Only for clients. Don't be fooled.
	multiplayer.server_disconnected.connect(func(): 	
		write("Server shut down or disconnected.")
		remove_player_data.rpc(1)
	)
	multiplayer.connection_failed.connect(func():
		write("Connection failed. Could not find or connect to server."))
	
	multiplayer.peer_connected.connect(func(id): 		
		write("Peer connected: " + str(id))
		server_connect_success.rpc()
	) 		# DOES NOT RUN FOR OTHER PEERS.
		
	multiplayer.peer_disconnected.connect(func(id): 	
		write("Peer disconnected: " + str(id)) 	# DOES NOT RUN FOR PEER.
		remove_player_data.rpc(multiplayer.get_unique_id())
	)
	
	%btn_joingame.pressed.connect(try_to_connect_to_server)
	%btn_creategame.pressed.connect(create_server)
	%btn_startgame.pressed.connect(func(): start_game.rpc())
	%line_YourName.text_changed.connect(func(newname): 
		if multiplayer.multiplayer_peer != null:
			send_name_data.rpc(multiplayer.get_unique_id(), newname)
	)
	pass

@rpc("any_peer", "call_local", "reliable")
func send_name_data(id, cname):
	client_names[id] = cname
	pass

@rpc("any_peer", "call_local", "reliable")
func start_game():
	get_tree().change_scene_to_file("res://scn_main.tscn")
	pass

func try_to_connect_to_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(Network.IP_ADRESS, Network.PORT)	
	multiplayer.multiplayer_peer = peer
	write("Trying to connect to " + str(Network.IP_ADRESS) + ":" + str(Network.PORT))
	pass

func create_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(Network.PORT)
	multiplayer.multiplayer_peer = peer
	write("Creating Server at " + str(Network.IP_ADRESS) + ":" + str(Network.PORT))
	server_connect_success() # Because we are the server.
	pass

@rpc("any_peer", "call_local", "reliable")
func server_connect_success():
	write("Server connection success!")
	send_player_data.rpc(multiplayer.get_unique_id())
	pass
