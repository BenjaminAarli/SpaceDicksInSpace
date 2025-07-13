@tool
extends Node3D

@onready var cube1 = $pot/Cube
@onready var cube2 = $pot/Cube_001
@onready var plantSprite = %Sprite3D

var models = {
	-1: $pot/Cube, 
	0:  $pot/Cube_001
}

@export var seed: PlantData: 
	set(value):
		seed = value
		check_stage()
		set_plant_image()
		pass
@export var stage = -1: 
	set(value):
		stage = value
		check_stage()
		set_plant_image()
		pass

func set_stage(_stage: int): 
	stage = _stage
	pass

func check_stage():
	pass

func set_plant_image():
	var max = seed.images.size() - 1
	var seed_img 		= seed.images[clamp(stage, 0, max)]
	plantSprite.texture = seed_img
	pass
