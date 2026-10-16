extends CharacterBody3D
class_name BaseItem

@export var coll: CollisionShape3D

# ITEM
@export_category("Item")
@export var item_name: String:
	set = s_item_name

@export_group("Use")
@export var max_uses: int = 1:
	set = s_max_uses

var uses: int = 0:
	set = s_uses

@export var delete_on_use: bool = true

@export var i_data: Dictionary #only use variable with a SET function (item name, max uses, uses)
var item_holder: BaseClass = null

# MOVEMENT
@export_category("Movement")

@export var deccel: float = 10.0 #friction multiplier
@export var air_deccel: float = 0.5 #friction multiplier in air

@export_group("Gravity")
@export var grv: float = 20.0
@export var ignore_gravity: bool = false
@export var ignore_gravity_when_dropped: bool = false

# VISUALS
@export_category("Visuals")
@export_range(-250, 250, 50) var spin_mult = 150
@export_range(-180, 180, 15) var z_rotation = -15
@export var def_rotation: Vector3
@export var use_rotation: bool = true #use rotation when not held
@export var use_rotation_when_held: bool = false #use rotation when held

@export var pivot: Node3D #node3d that holds the mesh


func _process(delta: float) -> void:
	if delete_on_use and uses >= max_uses:
		if is_held():
			item_holder.item = null
			item_holder.i_data.clear()
		queue_free()
	
	handle_rotation(delta)

func _physics_process(delta: float) -> void:
	if is_held():
		ignore_gravity = true
		coll.disabled = true
	else:
		if !ignore_gravity_when_dropped: ignore_gravity = false
		else: ignore_gravity = true
		coll.disabled = false
	
	handle_decceleration(delta)
	handle_gravity(delta)
	
	move_and_slide()

func is_held() -> bool:
	if item_holder != null: return true
	else: return false

@rpc("authority", "call_local", "unreliable")
func pickup():
	ignore_gravity = true
	item_holder = get_parent()
	
	await is_held()
	
	update_i_data(i_data)

@rpc("authority", "call_local", "unreliable")
func use(path):
	uses += 1

@rpc("authority", "call_local", "unreliable")
func throw(throw_dir: Vector3):
	ignore_gravity = ignore_gravity_when_dropped
	velocity = throw_dir
	velocity.y += grv * 0.25

func handle_decceleration(delta):
	if !is_held():
		velocity.x = move_toward(velocity.x, 0, get_deccel() * delta)
		velocity.z = move_toward(velocity.z, 0, get_deccel() * delta)

func get_spd() -> float:
	return 10.0

func get_deccel() -> float:
	if is_on_floor(): return get_spd() * deccel
	else: return get_spd() * air_deccel

func handle_gravity(delta):
	if !is_on_floor() and !ignore_gravity:
		velocity.y -= grv * delta

func handle_rotation(delta):
	if pivot == null: return
	
	if !use_rotation or (!use_rotation_when_held and is_held()):
		pivot.rotation_degrees = def_rotation
		return
	
	pivot.rotation_degrees.y += (1 * delta * spin_mult)
	pivot.rotation_degrees.z = z_rotation

#region item data
func update_i_data(new_data: Dictionary) -> Dictionary:
	print(new_data)
	i_data.merge(new_data, true)
	
	await is_held()
	
	if is_held():
		item_holder.i_data = i_data
		print("merging %s with %s" % [new_data, i_data])
	return i_data

func s_item_name(value: String) -> void:
	if item_name != value:
		item_name = value
	update_i_data({"item_name": item_name})

func s_max_uses(value: int) -> void:
	if max_uses != value:
		max_uses = value
	update_i_data({"max_uses": max_uses})

func s_uses(value: int) -> void:
	if uses != value:
		uses = value
	update_i_data({"uses": uses})

#endregion
