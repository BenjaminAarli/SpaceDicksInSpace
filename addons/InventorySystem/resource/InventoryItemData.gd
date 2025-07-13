extends Resource
class_name InventoryItemData

const dev_image = preload("../graphics/no_texture.png")
const shader 	= preload("../graphics/item_overlay.gdshader")

var grid_position  = Vector2i.ZERO
var grid_size  	   = Vector2i(1, 1)

var image : Texture2D = dev_image

var stack_size  	= 0
var stack_size_max  = 999

func get_slots_used():
	var used: Array[Vector2i] = []
	for x in grid_size.x:
		for y in grid_size.y: 
			used.append(Vector2i(grid_position + Vector2i(x, y)))
	return used

func set_image(tex: Texture2D):
	image = tex
	pass
