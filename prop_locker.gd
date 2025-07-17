extends MchBase

@export var anim: AnimationPlayer

func _ready() -> void:
	super()
	pass

var is_open = false
func interact(person):
	super(person)
	is_open = !is_open
	if is_open: anim.play("open")
	else: anim.play("close")
	pass
