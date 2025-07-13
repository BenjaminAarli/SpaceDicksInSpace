extends Resource
class_name PlantData

@export var plant_name = "Wheat"
@export var seed_image	: Texture2D 	= preload("res://data/images/plants/dev_plant_wheat_seeds.png")
@export var bundle_image: Texture2D 	= preload("res://data/images/plants/dev_plant_wheat_bundle.png")
@export var images: Array[Texture2D] 	= [preload("res://data/images/plants/dev_plant_wheat_00.png")]

@export var grow_time_per_tick = 2
