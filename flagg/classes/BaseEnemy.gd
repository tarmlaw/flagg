extends CharacterBody3D
class_name BaseEnemy

# HEALTH
@export_category("Health")
@export_group("Health")
@export var def_max_hp: int = 10
var max_hp: int = 10
@export var def_hp: int = 10
var hp: int = def_hp

@export var def_shield: int = 0
var shield: int = def_shield

var decay: int = 0

var if_timer: Timer
var if_time: float = 0.2
var dead: bool = false

@export var hurtbox: Hurtbox

signal i_got_a_booboo_ToT ## specifically dmg taken
signal health_changed ## anything other than dmg taken


# STATUS EFFECTS
@export var status_effect_handler: StatusEffectHandler


# STATES
@export_category("States")
@export var state_machine: Node3D
var current_state: Node


# MOVEMENT
@export_category("Movement")
@export_group("Basic Movement")
@export var walk_spd: float = 7.0 #speed on ground
@export var air_spd: float = 7.5 #speed in air
var spd: float #current speed
var def_spd_mult: float = 1.0
var spd_mult: float = def_spd_mult

@export var vary_speed: bool = true
@export var spd_range: Vector2 = Vector2(-2.5, 2.5)
var varied_spd = 0.0

@export var accel: float = 7.5 #acceleration multiplier on ground
@export var deccel: float = 10.0 #friction multiplier
@export var air_deccel: float = 0.5 #friction multiplier in air

@export var kb_timer: Timer
var kb_velocity: Vector3

@export var can_move: bool = true
var input_dir: Vector2 = Vector2.ZERO
var dir: Vector3 = Vector3.ZERO

@export_group("Slopes & Stairs")
@export var stair_ahead_ray: RayCast3D
@export var stair_below_ray: RayCast3D
@export var max_step_height: float = 0.5
var snapped_to_stairs_last_frame: bool = false
var on_floor_last_frame = -INF

@export_group("Jumping & Gravity")
@export_subgroup("Basic Jumping & Gravity")
@export var jmp: float = 2.0 # jump height
@export var jmp_time: float = 0.3 # time from ground to peak
@export var fall_time: float = 0.3 # time from peak to ground
var jmp_vel: float = (2.0 * jmp / jmp_time)
var jmp_grv: float = (-2.0 * jmp) / (jmp_time * jmp_time)
var fall_grv: float = (-2.0 * jmp) / (fall_time * fall_time)

@export var ignore_grv: bool = false

@export_subgroup("Coyote Jump")
var coyote_timer: Timer = null
var can_coyote: bool = false

@export_subgroup("Elevation & Fall Damage")
@export var min_fall_height: float = 4.5
@export var fall_distance: float = 0.0
var last_fall_distance: float = 0.0
var elevation: float = 0.0 #controller's elevation

@export var min_land_shake_height: float = 4.5

@export var fall_dmg: int = 1
@export var take_fall_damage: bool = true

# NAVIGATION
@export_category("Navigation")
@export var nav_agent: NavigationAgent3D
@export var nav_target: Node = null
var nav_pos: Vector3
var next_nav_pos: Vector3

@export var nav_update_rate: float = 0.5
var last_nav_update = nav_update_rate

@export var use_navigation: bool = false

var nav_distance: float = 0.0
var nav_dir: Vector2 = Vector2.ZERO

@export_group("Tracking")
@export var vision_ray: RayCast3D
@export var vision_angle: float = 190.0
@export var tracking_smoothing: float = 0.2


# ANIMATION, AUDIO, & VISUAL
@export_category("AAV")
@export_group("Animation")
@export var anim: AnimatedSprite3D

@export_group("Audio")

@export_group("Visual")
#@export var meshes_to_hide: Array[VisualInstance3D]
@export var visibility_notifier: VisibleOnScreenNotifier3D

# MISCELLANEOUS
@export_category("Miscellaneous")
@export var coll: CollisionShape3D
@export var death_poof_scale: Vector3 = Vector3(0.3, 0.3, 0.3)
@export var score: int = 10


func _enter_tree() -> void:
	pass

func _ready() -> void:
	#camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#health
	max_hp = def_max_hp + Global.round
	hp = max_hp
	shield = def_shield
	
	#states
	change_state("default")
	
	nav_target = Global.player
	use_navigation = true
	
	#movement
	if vary_speed: varied_spd = randi_range(spd_range.x, spd_range.y)


func _process(delta: float) -> void:
	# health
	handle_health()
	
	# states
	if current_state:
		current_state.handle_state(delta)
	
	# targeting
	if nav_target == null:
		use_navigation = false
		nav_target = Global.player
	
	handle_tracking()

func _physics_process(delta: float) -> void:
	if kb_timer.is_stopped():
		handle_movement(delta)
	else:
		velocity = kb_velocity
	
	handle_fall_height()
	
	if use_navigation:
		if kb_timer.is_stopped():
			handle_navigation_movement(delta)
		else:
			velocity = kb_velocity
	
	if !snap_up_stairs_check(delta):
		move_and_slide()
		snap_to_stairs_check()

func handle_health():
	#health
	max_hp = def_max_hp + Global.round
	
	hp = clampi(hp, 0, max_hp)
	if hp <= 0 and !dead:
		die()

func apply_healing(hp_healed: int, shield_healed: int = 0):
	if hp + hp_healed >= max_hp - (decay * 2):
		hp = max_hp - (decay * 2)
	else:
		hp += hp_healed
	
	shield += shield_healed
	health_changed.emit()

func apply_damage(damage: int, ignore_shield: bool = false):
	if if_timer:
		if !if_timer.is_stopped(): return
	
	if !ignore_shield:
		if damage <= shield: shield -= damage
		else:
			var r = shield - damage
			shield = 0
			hp += r
	else:
		hp -= damage
	
	i_got_a_booboo_ToT.emit()
	
	if damage > 0:
		pass
		
		#sfx_hit.play()
	
	if_timer = Timer.new()
	add_child(if_timer)
	if_timer.connect("timeout", func(): if_timer.queue_free())
	if_timer.start(if_time)

func die():
	dead = true
	visible = false
	Global.score += score
	queue_free()

func change_state(new_state: String):
	# switches to the new state
	if current_state: current_state.exit_state(self)
	current_state = state_machine.get_node(new_state)
	if current_state: current_state.enter_state(self)

func handle_movement(delta):
	#landing
	if is_on_floor(): land()
	
	if use_navigation: return
	
	#input
	#input_dir = Input.get_vector("left", "right", "forward", "backward")
	dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#normal grounded movement
	if dir and can_move:
		velocity.x = move_toward(velocity.x, dir.x * get_spd(), get_accel() * delta)
		velocity.z = move_toward(velocity.z, dir.z * get_spd(), get_accel() * delta)
	#no movement
	else:
		velocity.x = move_toward(velocity.x, 0, get_deccel() * delta)
		velocity.z = move_toward(velocity.z, 0, get_deccel() * delta)
	
	#gravity
	if !is_on_floor() and !ignore_grv:
		velocity.y += get_grv() * delta
	if ignore_grv: velocity.y = 0
	
	#jumping
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jmp_vel
	
		#elevation
		elevation = global_position.y
		fall_distance = 0.0
		
		can_coyote = false
		if coyote_timer:
			coyote_timer.stop()
			coyote_timer = null
	
	#coyote jumping
	if Input.is_action_pressed("jump") and !is_on_floor():
		if !coyote_timer: return
		if coyote_timer.is_stopped(): return
		velocity.y = jmp_vel
		
		can_coyote = false
		coyote_timer.stop()
	
	
	if !is_on_floor():
		#coyote
		if can_coyote and coyote_timer == null:
			coyote_timer = Timer.new()
			coyote_timer.wait_time = 0.2
			coyote_timer.one_shot = true
			coyote_timer.autostart = true
			add_child(coyote_timer)
			coyote_timer.timeout.connect(func():
				can_coyote = false
				coyote_timer.queue_free());
		
		#elevation
		if coyote_timer and !coyote_timer.is_stopped():
			elevation = global_position.y
			fall_distance = 0.0

func handle_fall_height():
	if is_on_floor(): return
	fall_distance = abs(elevation - global_position.y)

func land(ignore_fall_damage: bool = false):
	if !can_coyote:
		if fall_distance >= min_land_shake_height:
			pass
		
		if fall_distance >= min_fall_height and take_fall_damage and !ignore_fall_damage:
			apply_damage(roundf(fall_dmg * (fall_distance - min_fall_height)), true)
		last_fall_distance = fall_distance
	
	fall_distance = 0
	
	on_floor_last_frame = Engine.get_physics_frames()
	can_coyote = true

func apply_knockback(direction: Vector3, force: float, duration: float = 0.15):
	if force == 0: return
	kb_velocity.x = (direction * force).x
	kb_velocity.y = (direction * force).y / 2
	kb_timer.start(duration)

#stair/ladder shit i copied
func is_surface_too_steep(normal : Vector3) -> bool:
	return normal.angle_to(Vector3.UP) > self.floor_max_angle #if the angle of the floor (normal) > the max floor angle, the floor is too steep

func run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	if !result:
		result = PhysicsTestMotionResult3D.new()
	var params = PhysicsTestMotionParameters3D.new()
	params.from = from
	params.motion = motion
	return PhysicsServer3D.body_test_motion(self.get_rid(), params, result)

func snap_to_stairs_check():
	var snapped = false
	var floor_below : bool = stair_below_ray.is_colliding() and !is_surface_too_steep(stair_below_ray.get_collision_normal())
	var was_on_floor = Engine.get_physics_frames() - on_floor_last_frame == 1
	if !is_on_floor() and velocity.y <= 0 and (was_on_floor or snapped_to_stairs_last_frame) and floor_below:
		var body_test_result = PhysicsTestMotionResult3D.new()
		if run_body_test_motion(self.global_transform, Vector3(0, -max_step_height, 0), body_test_result):
			var translate_y = body_test_result.get_travel().y
			self.position.y += translate_y
			apply_floor_snap()
			snapped = true
	snapped_to_stairs_last_frame = snapped

func snap_up_stairs_check(delta) -> bool:
	if !is_on_floor() and !snapped_to_stairs_last_frame:
		return false
	var expected_motion = self.velocity * Vector3(1, 0, 1) * delta
	var clear_step_pos = self.global_transform.translated(expected_motion + Vector3(0, max_step_height * 2, 0))
	
	var down_check_result = KinematicCollision3D.new()
	if (self.test_move(clear_step_pos, Vector3(0,-max_step_height*2,0), down_check_result)
	and (down_check_result.get_collider().is_class("StaticBody3D") or down_check_result.get_collider().is_class("CSGShape3D"))):
		var step_height = ((clear_step_pos.origin + down_check_result.get_travel()) - self.global_position).y
		# Note I put the step_height <= 0.01 in just because I noticed it prevented some physics glitchiness
		# 0.02 was found with trial and error. Too much and sometimes get stuck on a stair. Too little and can jitter if running into a ceiling.
		# The normal character controller (both jolt & default) seems to be able to handled steps up of 0.1 anyway
		if step_height > max_step_height or step_height <= 0.01 or (down_check_result.get_position() - self.global_position).y > max_step_height: return false
		stair_ahead_ray.global_position = down_check_result.get_position() + Vector3(0,max_step_height,0) + expected_motion.normalized() * 0.1
		stair_ahead_ray.force_raycast_update()
		if stair_ahead_ray.is_colliding() and not is_surface_too_steep(stair_ahead_ray.get_collision_normal()):
			#_save_camera_pos_for_smoothing()
			self.global_position = clear_step_pos.origin + down_check_result.get_travel()
			apply_floor_snap()
			snapped_to_stairs_last_frame = true
			return true
	return false

func get_spd() -> float:
	if is_on_floor(): return (walk_spd + varied_spd) * spd_mult
	else: return (air_spd + varied_spd) * spd_mult

func get_accel() -> float:
	return get_spd() * accel

func get_deccel() -> float:
	if is_on_floor(): return get_spd() * deccel
	else: return get_spd() * air_deccel

func get_grv() -> float:
	jmp_vel = (2.0 * jmp / jmp_time)
	jmp_grv = (-2.0 * jmp) / (jmp_time * jmp_time)
	fall_grv = (-2.0 * jmp) / (fall_time * fall_time)
	
	if ignore_grv:
		return 0.0
	else:
		if velocity.y > 0.0:
			return jmp_grv
		else:
			return fall_grv

func handle_navigation_movement(delta):
	if !use_navigation: return
	
	look_at(nav_target.global_position, Vector3.UP)
	rotation.x = 0
	
	if !can_move:
		velocity.x = 0
		velocity.z = 0
		return
	
	nav_agent.max_speed = max(spd, get_spd())
	
	last_nav_update += delta
	if last_nav_update >= nav_update_rate:
		last_nav_update = 0.0
		get_nav_target()
	
	nav_dir = Vector2(nav_pos.direction_to(next_nav_pos).x, nav_pos.direction_to(next_nav_pos).z).normalized()
	
	var new_velocity: Vector3
	new_velocity.x = move_toward(velocity.x, nav_dir.x * get_spd(), get_accel() * delta)
	new_velocity.z = move_toward(velocity.z, nav_dir.y * get_spd(), get_accel() * delta)
	
	if !is_on_floor():
		new_velocity.y += get_grv()
	
	# handle avoidance
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_3d_velocity_computed(new_velocity)
	
	# find distance
	nav_distance = global_position.distance_to(nav_target.global_position)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if !use_navigation: return
	velocity = safe_velocity #if !dead
	#velocity = Vector2.ZERO #else ^

func get_nav_target():
	if !use_navigation: return
	
	if nav_target != null:
		nav_agent.target_position = nav_target.global_position
	
	if nav_agent.is_navigation_finished():
		return
	nav_pos = self.global_position
	next_nav_pos = nav_agent.get_next_path_position()

func handle_tracking():
	if !nav_target: return
	
	var nav_idir = (nav_target.global_transform.origin - global_transform.origin).normalized()
	var fdir = -global_transform.basis.z
	var angle_deg = rad_to_deg(acos(clamp(fdir.dot(nav_idir), -1.0, 1.0)))
	if angle_deg > vision_angle * 0.5: return
	
	var ray_fdir = -vision_ray.global_transform.basis.z
	var new_ray_fdir = ray_fdir.slerp(nav_idir, tracking_smoothing).normalized()
	vision_ray.look_at(vision_ray.global_transform.origin + new_ray_fdir, Vector3.UP)

func target_in_sight() -> bool:
	if nav_target and vision_ray:
		if vision_ray.get_collider() == nav_target:
			return true
		else: return false
	else: return false
