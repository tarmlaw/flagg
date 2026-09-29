extends Node
class_name GooseState

var o #owner
var active: bool = false

@export var movement_override: bool = false
@export var anim_override: bool = false
@export var spd_mult: float = 0.0
@export var ignore_grv: bool = false

@export_group("Projectile")
@export var projectile: PackedScene
@export var count: int = 1
@export var arc: float = 0.0
@export var rate: float = 1.0
@export var max_spread: int = 1
@export var projectile_position: Vector3
@export var projectile_timer: Timer
@export var projectile_shake_strength: float = 0.5
@export var projectile_shake_time: float = 0.1

@export_group("Timing")
@export var use_time: bool = true
@export var state_time: float = 1.0
var state_timer: Timer
@export var fallback_state: GooseState

signal state_entered
signal state_exited


func enter_state(owner_node):
	if use_time:
		if state_timer: state_timer.queue_free()
		state_timer = Timer.new()
		state_timer.wait_time = state_time
		state_timer.one_shot = true
		state_timer.autostart = true
		if fallback_state: state_timer.timeout.connect(func(): o.change_state(fallback_state.name))
		else: state_timer.timeout.connect(func(): o.change_state("default"))
		add_child(state_timer)
	
	o = owner_node
	o.spd_mult += spd_mult
	o.ignore_grv = ignore_grv
	
	state_entered.emit()

func handle_state(_delta):
	if movement_override: o.can_move = false
	else: o.can_move = true
	
	handle_animation()

func handle_animation():
	if anim_override: return
	#if o.dead: return

func shoot():
	if !projectile_timer.is_stopped(): return
	projectile_timer.start(rate)
	
	var origin_rotation = -o.camera.global_transform.basis.z.normalized()
	
	for i in count:
		var p: BaseProjectile = projectile.instantiate()
		get_tree().current_scene.add_child(p)
		
		if count == 1:
			p.global_rotation_degrees = origin_rotation
		elif count > 1:
			var arc_rad = deg_to_rad(arc)
			var inc = ((arc_rad / (count - 1)) * i) - arc_rad / 2
			p.f_dir = origin_rotation + Vector3(inc, 0, inc)
			print(p.f_dir.snapped(Vector3(.5,.5,.5)), " ", snapped(deg_to_rad(inc), 0.5))
			
			
			
			p.s_dir = p.f_dir.rotated(Vector3.FORWARD, p.rotation_degrees.y)
		
		p.global_position = o.global_position + projectile_position
	
	#if projectile_timer.is_stopped():
		#projectile_timer.start(rate)
		#var origin_rotation
		#
		#if is_equal_approx(o.shoot_ray.rotation_degrees, -90):
			#projectile_position = Vector2(2, -13)
			#origin_rotation = deg_to_rad(-90)
		#
		#elif is_equal_approx(o.shoot_ray.rotation_degrees, 90):
			#projectile_position = Vector2(5, 7)
			#origin_rotation = deg_to_rad(90)
		#
		#else:
			#projectile_position = Vector2(12, -4)
			#if !o.flipped: origin_rotation = deg_to_rad(0)
			#else: origin_rotation = deg_to_rad(180)
			#
		#if !o.flipped: projectile_position.x = abs(projectile_position.x)
		#else: projectile_position.x = -abs(projectile_position.x)
		#
		#for i in count:
			#var p = projectile.instantiate()
			#
			#if count == 1:
				#p.rotation_degrees = origin_rotation
			#else:
				#var arc_rad = deg_to_rad(arc)
				#var inc = arc_rad / (count - 1)
				#p.rotation_degrees = (origin_rotation + inc * i - arc_rad / 2)
			#
			#p.global_position = o.global_position + projectile_position
			#p.global_position.y += randi_range(-max_spread, max_spread)
			#
			#p.use_enemy_collision_layers = false
			#
			#get_tree().current_scene.add_child(p)
			#p.flipped = o.flipped
			#
			##o.sfx_shoot.play()
			#o.apply_camera_shake(projectile_shake_strength, projectile_shake_time)
			#Input.start_joy_vibration(0, 1.0, 0.25, 0.25)

func exit_state(owner_node):
	if state_timer: state_timer.queue_free()
	
	o.spd_mult -= spd_mult
	o.ignore_grv = false
	
	state_exited.emit()
