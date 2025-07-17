extends Node

# MY IP : "88.88.7.210"

var players	: Array[int] = []
var IP_ADRESS 	= "127.0.0.1"
var PORT 		= 3465

var disconnected_players_positions: Dictionary[int, Vector3] = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(func(id): pass)
	multiplayer.peer_disconnected.connect(func(id): pass)
	pass
