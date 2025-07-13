extends RigidBody3D
class_name PropTool

@export_file(".tres") var resource
var message_pickup = "Picked up a Tool."

func _ready() -> void:
	resource = ResourceLoader.load(resource)
	add_to_group("Effected_By_Gravity_Change")
	add_to_group("Pickupable")
	pass

func pick_up() -> Resource:
	if resource != null:
		GlobalChatlog.write(message_pickup)
		die.rpc()
		return resource
	else: return null

@rpc("any_peer", "call_local", "reliable")
func die():	queue_free()
