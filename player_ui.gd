extends Control
class_name PlayerUI

@onready var item_texture_main = %Tex_Equpped0
@onready var item_texture_2nd  = %Tex_Equpped1
@onready var item_texture_3rd  = %Tex_Equpped2

func set_item_icon(items: Array):
	if items.size() == 0: clear_item_icons(); return
	item_texture_main.texture = items[0].icon if items[0] != null else null
	item_texture_2nd.texture  = items[1].icon if items.get(1) != null else null
	item_texture_3rd.texture  = items[2].icon if items.get(2)  != null else null
	pass

func clear_item_icons():
	item_texture_3rd.texture  = null
	item_texture_2nd.texture  = null
	item_texture_main.texture = null
	pass

func clear_item_icon():
	item_texture_main.texture = null
	pass
