extends RichTextLabel
class_name Chatlog 

func _ready() -> void:
	add_to_group("Chatlog")
	pass

func write(t: String):
	text += t + "\n"
	pass
