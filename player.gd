extends CharacterBody3D
class_name PlayerBody

signal player_action(player)

@onready var cam: Camera3D = %Camera3D
@onready var ray_lookat: RayCast3D = %Ray_LookAt
@onready var node_item_holder = %Item

#var item_index 		= -1
var item_equipped 	= []
const MOVE_SPEED_MAX = 6
var move_speed = MOVE_SPEED_MAX

var in_menu := false:
	set(value):
		in_menu = value

var in_space = false: 
	set(value): 
		in_space = value
		velocity = Vector3.ZERO

func _ready() -> void:
	%Label3D.text = name
	add_to_group("Effected_By_Gravity_Change")
	add_to_group(Globals.groups.player)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if is_multiplayer_authority():
		%HideMe.hide()
		%HideMe2.hide()
		%Camera3D.current = true
	multiplayer.peer_disconnected.connect(func(id): 
		if id == multiplayer.multiplayer_peer:
			Network.disconnected_players_positions[id] = global_position
			queue_free()
		pass)
	multiplayer.peer_connected.connect(func(id):
		if Network.disconnected_players_positions.has(id):
			global_position = Network.disconnected_players_positions[id]
			Network.disconnected_players_positions.erase(id)
			print("Added a global position to disconnected_players_positions")
	)
	sync_state.rpc(multiplayer.get_unique_id(), global_position, rotation_degrees, %pivot.rotation_degrees)
	pass

@rpc("any_peer", "call_remote", "reliable")
func sync_state(id: int, pos: Vector3, _rotation: Vector3, pivot_rotation: int):
	if id != int(name): return
	global_position 		= pos
	rotation_degrees 		= _rotation
	%pivot.rotation_degrees = pivot_rotation
	pass

func move_dir() -> Vector3:
	var vel = Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		vel += -cam.global_basis.z
	if Input.is_key_pressed(KEY_S):
		vel +=  cam.global_basis.z
	if Input.is_key_pressed(KEY_A):
		vel += -cam.global_basis.x
	if Input.is_key_pressed(KEY_D):
		vel +=  cam.global_basis.x
	vel = vel.normalized()
	return vel

func _physics_process(delta: float) -> void:
	if get_tree().get_multiplayer().has_multiplayer_peer():
		if is_multiplayer_authority():
			if in_space:
				movement_in_space(delta)
			else:
				velocity = movement_in_ship(delta)
				if Input.is_key_pressed(KEY_SHIFT): velocity *= 1.5
				if not is_on_floor(): velocity.y = clamp(velocity.y - delta, 0, 9.5)-9.5
				else: velocity.y = 0
			move_and_slide()
	pass

var _speed = Vector3.ZERO
func movement_in_ship(delta):
	var dir = move_dir()
	_speed = _speed.move_toward(dir, delta * 6)
	var vel = _speed * 4
	if in_menu: return Vector3.ZERO
	else: return vel

var velocity_space := Vector3.ZERO
var PVel := Vector3.ZERO # Delete later.
func movement_in_space(delta):
	var input_dir := move_dir()
	var vertical_thrust := 0.0
	const thrust_speed 	:= 4.0
	const max_speed 	:= 8.0
	const dampening 	:= 2.0 
	if Input.is_key_pressed(KEY_SPACE):
		vertical_thrust += thrust_speed
	if Input.is_key_pressed(KEY_CTRL):
		vertical_thrust -= thrust_speed
	var thrust = (input_dir * thrust_speed) + Vector3(0, vertical_thrust * thrust_speed, 0)
	velocity += thrust * delta
	# Clamp movement speed.
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	# Reduce speed until stop moving.
	if thrust == Vector3.ZERO:
		velocity = velocity.move_toward(Vector3.ZERO, dampening * delta)
	
	# Bounce on walls
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)
		velocity = velocity.normalized() * (velocity.length() / 2)
	pass

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventKey:
			if Input.is_action_just_pressed("inventory"):
				%PlayerUI_Inventory.visible = !%PlayerUI_Inventory.visible
			if Input.is_action_just_pressed("Interact"):
				player_action.emit(self)
				if ray_lookat.is_colliding() and ray_lookat.get_collider().is_in_group("Interactable"):
					var target = ray_lookat.get_collider()
					target.interact(self)
				if ray_lookat.is_colliding() and ray_lookat.get_collider().is_in_group("Pickupable"):
					if item_equipped.size() >= 3: print("to many items: ", str(item_equipped)); return
					var look_item = ray_lookat.get_collider()
					var _item = look_item.pick_up() as ItemTool # The Resource
					equip_item.rpc(_item.resource_path, int(name))
					look_item.queue_free()
			if Input.is_action_just_pressed("FPS_Item_Drop"):
				drop_item.rpc(int(name))
				pass

@rpc("any_peer", "call_local", "reliable")
func drop_item(id):
	if int(name) != id: return
	if item_equipped.front() != null:
		# Create Prop and throw it.
		var drop_pos: Vector3 = %Camera3D.global_position - (%Camera3D.global_basis.z * 1.5)
		var item = item_equipped.front()
		var prop: RigidBody3D = item.prop.instantiate()
		get_parent().add_child(prop)
		if %Ray_LookAt.is_colliding():
			drop_pos = %Ray_LookAt.get_collision_point()
			drop_pos = drop_pos.lerp(%Camera3D.global_position, 0.75)
		prop.global_position = drop_pos
		prop.global_rotation_degrees = rotation_degrees
		prop.apply_central_impulse(-%Camera3D.global_basis.z * 5)
		if in_space: 
			prop.gravity_scale = 0
			prop.apply_central_impulse(PVel)
		else: prop.apply_central_impulse(_speed)
		# Remove item from the equipped item.
		item_equipped.pop_front()
		%PlayerUI.clear_item_icon()
		if item_equipped.size() > 0: change_item(0)
		while node_item_holder.get_child_count() > 0:
			node_item_holder.remove_child(node_item_holder.get_child(0))
	pass

@rpc("any_peer", "call_local", "reliable")
func equip_item(itempath: String, id):
	if int(name) != id: return
	GlobalChatlog.write("Weapon Equiped")
	var item = load(itempath)
	# Set item
	if item_equipped.size() <= 2: 
		item_equipped.append(item)
		GlobalChatlog.write(str(item_equipped.size()))
	# Remove old item.
	if node_item_holder.get_child_count() > 0:
		node_item_holder.remove_child(node_item_holder.get_child(0))
	# Set the item actually. 
	change_item.rpc(item_equipped.size() - 1)
	pass

@rpc("any_peer", "call_local", "reliable")
func change_item(index: int):
	if item_equipped.size() == 0: return # If no items found.
	
	var i = item_equipped.get(index)
	if i != null:
		item_equipped.remove_at(index)
		item_equipped.push_front(i)
	
	GlobalChatlog.write("Item Changed to " + str(index))
	# Remove old items.
	while node_item_holder.get_child_count() > 0: node_item_holder.remove_child(node_item_holder.get_child(0))
	# Add item to FPSScane.
	var item: ItemTool = item_equipped.front()
	if item == null: return
	var i_scene = item.scene.instantiate()
	i_scene.name = str(name)
	node_item_holder.add_child(i_scene)
	i_scene.set_multiplayer_authority(int(name))
	%PlayerUI.set_item_icon(item_equipped) # UI Set Icon.
	pass

func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventKey:
			if Input.is_key_pressed(KEY_1): change_item.rpc(0)
			if Input.is_key_pressed(KEY_2): change_item.rpc(1)
			if Input.is_key_pressed(KEY_3): change_item.rpc(2)
		if event is InputEventMouseMotion and not in_menu: 
			rotate_y(-event.relative.x / 750)
			$pivot.rotate_x(-event.relative.y / 750)
			$pivot.rotation_degrees.x = clamp($pivot.rotation_degrees.x, -90, 90)
		pass
