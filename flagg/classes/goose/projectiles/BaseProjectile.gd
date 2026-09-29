extends CharacterBody3D
class_name BaseProjectile


# HEALTH & DAMAGE
@export_category("Health")
@export var lifetime: float = 10 ## -1 = no timer
var death_timer: Timer
@export var use_timer: bool = true
@export var hitbox: Hitbox

# MOVEMENT
@export_category("Movement")
@export var spd: float = 15
var accel = spd * 10.0
var dir: Vector3
var f_dir: Vector3 ## forward
var s_dir: Vector3 ## spread

@export var use_gravity: bool = false
@export var grv: float = 60

## ARCED MOVEMENT
#@export_category("Arced Movement")
#@export var use_arced_movement: bool = false
#@export var arc_angle: float = 0.0
#@export var arc_distance: int = 64
#var arc_grv: float = 9.8
#var initial_pos: Vector3 = position
#var fake_spd: float = 0.0
#var arced_spd: float = 4
#
#var arc_time: float = 0.0
#var z_axis: float = 0.0
#
#var launched: bool = false
#
#@export var die_on_land: bool = true
#
#@export var projectile_pivot: Node3D

# HOMING
@export_category("Homing Movement")
@export var use_homing: bool = false
@export var steer_spd: float = 5.0
@export var homing_target: Vector3
@export var rotate_when_homing: bool = true

## RICOCHET
#@export_category("Ricochet")
#@export var use_ricochet: bool = false
#@export var ricochet_rcv: float = 0.1
#@export var ricochet_mult: Vector2 = Vector2(-1, -1)
#@export var extra_ricochet_forces: Vector3 = Vector3.ZERO
#var ricochet_timer: Timer = null

# MISCELLANEOUS
@export_category("Miscellaneous")
@export var coll: CollisionShape3D
@export var use_enemy_collision_layers: bool = false
@export var die_on_collision: bool = true
@export var anim: AnimationPlayer
@export var default_animation: String = "default"
@export var pivot: Node3D
var played_once: bool = false
var flipped: bool = false


func _ready() -> void:
	if use_timer:
		death_timer = Timer.new()
		death_timer.wait_time = lifetime
		death_timer.one_shot = true
		death_timer.autostart = true
		death_timer.connect("timeout", die, 1)
		add_child(death_timer)
	
	#if use_enemy_collision_layers:
		#set_collision_layer_value(3, false)
		#set_collision_layer_value(4, true)
		#hitbox.set_collision_layer_value(3, false)
		#hitbox.set_collision_layer_value(4, true)
	#else:
		#set_collision_layer_value(3, true)
		#set_collision_layer_value(4, false)
		#hitbox.set_collision_layer_value(3, true)
		#hitbox.set_collision_layer_value(4, false)
	
	#if use_arced_movement:
		#await get_tree().process_frame
		#launch(global_position)
		#return
	
	dir = f_dir + s_dir

func _process(delta: float) -> void:
	if Global.player == null: return
	if Global.player.dead: queue_free()
	if Global.player: homing_target = Global.player.global_position
	
	if die_on_collision and !hitbox.is_connected("hit_something", _on_hitbox_hit_something):
		hitbox.connect("hit_something", _on_hitbox_hit_something)
	
	handle_animation()

func _physics_process(delta: float) -> void:
	if use_homing:
		handle_homing_movement(delta)
	
	if die_on_collision:
		if is_on_wall() or is_on_floor() or is_on_ceiling():
			if death_timer: death_timer.queue_free()
			die()
	
	#if use_arced_movement:
		#handle_arced_movement(delta)
		#return
	
	dir = f_dir + s_dir
#	dir = Vector2.RIGHT.rotated(rotation_degrees)
	#dir = f_dir.rotated(Vector3.FORWARD, rotation_degrees.y)
	#dir = (Vector3(rotation_degrees.x, rotation_degrees.y, rotation_degrees.z)).normalized()
	
	velocity.x = move_toward(velocity.x, dir.x * spd, accel * delta)
	velocity.y = move_toward(velocity.y, dir.y * spd, accel * delta)
	velocity.z = move_toward(velocity.z, dir.z * spd, accel * delta)
	
	if pivot: pivot.basis = (Basis.looking_at(velocity, Vector3.UP))
	coll.global_rotation = hitbox.global_rotation
	coll.global_position = hitbox.global_position
	
	if use_gravity:
		velocity.y += grv * delta
	
	move_and_slide()
	
	#var collision = move_and_collide(velocity)
	#
	#if collision:
		#if die_on_collision: die()
		#else:
			#if !use_ricochet: return
			#if ricochet_timer and !ricochet_timer.is_stopped(): return
			#elif ricochet_timer and ricochet_timer.is_stopped(): ricochet_timer.queue_free()
			#
			#ricochet_timer = Timer.new()
			#ricochet_timer.wait_time = ricochet_rcv
			#ricochet_timer.one_shot = true
			#add_child(ricochet_timer)
			#ricochet_timer.start()
			#
			#apply_ricochet(collision)

#func apply_ricochet(collision):
	#velocity = velocity.bounce(-collision.get_normal())
	#dir *= ricochet_mult
	#
	#apply_forces(extra_ricochet_forces)

#func apply_forces(extra_forces: Vector3 = Vector3.ZERO):
	#velocity.x = extra_forces.x * extra_forces.z * sign(-dir.x)
	#velocity.y = extra_forces.y * extra_forces.z

#func launch(start_position: Vector2):
	#initial_pos = start_position
	#fake_spd = pow(arc_distance * grv / sin(2 * deg_to_rad(arc_angle)), 0.5)
	#
	#global_position = initial_pos
	#arc_time = 0.0
	#z_axis = 0.0
	#launched = true
#
#func handle_arced_movement(delta):
	#follow_projectile_pivot()
	#move_and_slide()
	#arc_time += delta * spd * 2
	#
	#if flipped:
		#dir = Vector2(-1, 0)
	#else:
		#dir = Vector2(1, 0)
	#
	#if launched:
		#z_axis = fake_spd * sin(deg_to_rad(arc_angle)) * arc_time - 0.5 * grv * pow(arc_time, 2)
		#if z_axis > 0:
			#var x_axis: float = fake_spd * cos(deg_to_rad(arc_angle)) * arc_time
			#global_position = initial_pos + dir * x_axis
			#
			#projectile_pivot.position.y = -z_axis
		#else:
			#if die_on_land: die()
			#else:
				#velocity.y += grv
				#if is_on_floor(): die()
#
#func follow_projectile_pivot():
	#coll.position = projectile_pivot.position
	#hitbox.position = projectile_pivot.position
	#anim.position = projectile_pivot.position

func handle_homing_movement(delta: float):
	dir = seek()
	
	anim.rotation_degrees = global_rotation_degrees
	
	#if rotate_when_homing:
		#coll.look_at(homing_target)
		#hitbox.look_at(homing_target)
		#anim.look_at(homing_target)
	#else:
		#coll.rotation_degrees = 0
		#hitbox.rotation_degrees = 0
		#anim.rotation_degrees = 0

func seek() -> Vector3:
	var steer: Vector3 = Vector3.ZERO
	var idir: Vector3 = global_position.direction_to(homing_target) * spd
	
	steer = (idir - velocity).normalized() * steer_spd
	return steer

func die():
	visible = false
	await get_tree().create_timer(0.05).timeout
	queue_free()

func handle_animation(): ##handle in projectile script
	if anim == null: return
	
	#if rotate_when_homing and !use_homing: anim.global_rotation = global_rotation_degrees
	#elif rotate_when_homing and use_homing: look_at(homing_target)
	#else: anim.global_rotation = 0
	
	if !played_once:
		anim.play(default_animation)
		played_once = true

#func _on_death_timer_timeout() -> void:
	#die()
#
func _on_hitbox_hit_something(area: Hurtbox) -> void:
	die()
