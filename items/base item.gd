extends CharacterBody3D
class_name BaseItem

@export var coll: CollisionShape3D

# ITEM
@export_category("Item")
@export var item_name: String

@export_group("Use")
@export var max_uses: int = 1
var uses: int = 0

@export var delete_on_use: bool = true


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
	if delete_on_use and uses >= max_uses: queue_free()
	
	handle_rotation(delta)

func _physics_process(delta: float) -> void:
	#disable coll when held
	if get_parent() != get_tree().current_scene: coll.disabled = true
	else: coll.disabled = false
	
	handle_decceleration(delta)
	handle_gravity(delta)
	
	move_and_slide()

func pick_up(picked_up_by):
	ignore_gravity = true
	
	reparent(picked_up_by.item_holder, false)
	picked_up_by.object = self

func use(controller: Node3D):
	uses += 1

func throw(throw_dir: Vector3):
	ignore_gravity = ignore_gravity_when_dropped
	velocity = throw_dir
	velocity.y += grv * 0.25

func handle_decceleration(delta):
	if get_parent() == get_tree().current_scene: #checks if the item's not being held
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
	
	if !use_rotation or (!use_rotation_when_held and get_parent() != get_tree().current_scene):
		pivot.rotation_degrees = def_rotation
		return
	
	pivot.rotation_degrees.y += (1 * delta * spin_mult)
	pivot.rotation_degrees.z = z_rotation
