extends CharacterBody3D
class_name Projectile

# HEALTH & DAMAGE
@export_category("Health")
@export var lifetime: float = 2.0
@export var death_timer: Timer
@export var coll: CollisionShape3D
@export var hitbox: Hitbox

# MOVEMENT
@export_category("Movement")
@export var spd: float = 15
var accel = spd * 10.0
var dir: Vector3

# MISCELLANEOUS
@export_category("Miscellaneous")
@export var anim: AnimatedSprite3D


func _ready() -> void:
	##set owner node in projectile script
	death_timer.connect("timeout", die)
	hitbox.connect("hit_something", die)
	
	#death_timer.start(lifetime)
	#var r = randi_range(1, 2)
	#if r == 1:
		#anim.flip_v = true
	#
	#if use_enemy_collision_layers:
		#set_collision_layer_value(3, false)
		#set_collision_layer_value(5, true)
		#hitbox.set_collision_layer_value(3, false)
		#hitbox.set_collision_layer_value(5, true)
	#else:
		#set_collision_layer_value(3, true)
		#set_collision_layer_value(5, false)
		#hitbox.set_collision_layer_value(3, true)
		#hitbox.set_collision_layer_value(5, false)
	#
	#dmg = def_dmg
	#
	#if use_arced_movement:
		#await get_tree().process_frame
		#launch(global_position)
		#return
	#dir = Vector2.RIGHT.rotated(rotation_degrees)
	pass

func _process(delta: float) -> void:
	handle_animation()

func _physics_process(delta: float) -> void:
	dir = transform.basis * Vector3.FORWARD * delta
	#dir = Vector3.FORWARD.rotated(Vector3.UP, rotation_degrees.y)
	velocity.x = move_toward(velocity.x, dir.x * spd, accel * delta)
	velocity.z = move_toward(velocity.z, dir.z * spd, accel * delta)
	
	var collision = move_and_collide(velocity)
	
	if collision:
		die()

func die():
	visible = false
	await get_tree().create_timer(0.05).timeout
	queue_free()

func handle_animation():
	anim.play("default")
#
#func _on_death_timer_timeout() -> void:
	#die()
#
#func _on_hitbox_hit_something() -> void:
	#die()
