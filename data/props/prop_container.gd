extends Node3D
class_name PropContainer

@export var anim: AnimationPlayer
@export var UINode: Control
var inside = []

func _ready() -> void:
	add_to_group("Interactable")
	%UINode.hide()
	%PlayerLeaveArea.body_entered.connect(func(body): 
		if body.is_in_group(Globals.groups.player):
			inside.append(body)
		pass)
	%PlayerLeaveArea.body_exited.connect(func(body): 
		if body.is_in_group(Globals.groups.player): 
			ui_close()
			inside.remove_at(inside.find(body))
		pass)
	pass

func interact(toucher: PlayerBody):
	var r = ui_open_close()
	if r: toucher.in_menu = true
	else: toucher.in_menu = false
	pass

func ui_open_close():
	if UINode.visible: ui_close(); return false
	else: 				ui_open(); 	return true
	pass

func ui_open():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	UINode.show()
	anim.play("open")
	pass

func ui_close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	UINode.hide()
	anim.play("close")
	pass
