extends Area3D
class_name MchBase

signal ui_toggled(state: bool)

func _ready() -> void:
	add_to_group("Interactable")
	%UINode.hide()
	%PlayerLeaveArea.body_exited.connect(func(body):
		if body.is_in_group(Globals.groups.player):
			if body.is_multiplayer_authority():
				ui_close()
		pass)
	pass

# UI Openers and Closers.
func interact(interactor: PlayerBody): 
	var r = ui_open_close()
	if r: interactor.in_menu = true
	else: interactor.in_menu = false
	pass

func ui_open_close() -> bool:
	if %UINode.visible: ui_close(); ui_toggled.emit(false); return false
	else: 				ui_open(); 	ui_toggled.emit(true);  return true

func ui_open():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	%UINode.show()
	pass

func ui_close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	%UINode.hide()
	pass
