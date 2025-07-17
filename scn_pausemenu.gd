extends Control

func _on_disconnect_pressed() -> void:
	multiplayer.multiplayer_peer = null
	pass
