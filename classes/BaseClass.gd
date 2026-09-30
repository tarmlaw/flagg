extends CharacterBody3D
class_name BaseClass

# CAMERA & UI
@export_category("Camera & UI")
@export_group("Camera")
@export var pivot: Node3D
@export var camera: Camera3D

@export_subgroup("Sensitivity")
@export var mouse_sens_h: float = 0.4
@export var mouse_sens_v: float = 0.4
@export var controller_sens_h: float = 0.2
@export var controller_sens_v: float = 0.2

@export_subgroup("Camera Tilt")
@export var z_camera_tilt: float = 0.02 #camera tilt on ths z axis
@export var x_camera_tilt: float = 0.01 #camera tilt on the x axis

@export_subgroup("Headbob")
@export var headbob_freq: float = 2.0
@export var headbob_amp: float = 0.04
@export var t_bob: float = 0.0 #determines how far along the sine wave the bob is
var def_cam_origin: Vector3

@export_subgroup("Camera Shake", "camera")
@export var camera_shake_strength: float = 0.0 # camera shake intensity
@export var camera_shake_time: float = 0.0 # camera shake length
@export var camera_shake_reduction_rate: float = 5.0 # how quick the shake effect decays
@export var camera_shake_tick: float = 0.0
@export var camera_shake_tick_speed: float = 20.0
var camera_shake_noise = FastNoiseLite.new()

@export var shake_camera_when_landing: bool = true

@export_subgroup("Miscellaneous")
@export var head_follow_camera: bool = true
@export var look_at_mod: LookAtModifier3D

@export_group("UI")
@export var ui: CanvasLayer

# HEALTH
@export_category("Health")
@export_group("Health")
@export var max_hp: int = 10
@export var def_hp: int = 10
var hp: int = def_hp

@export var def_shield: int = 4
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


# INTERACTION
@export_category("Interaction")
@export_group("Interaction")
@export var item_holder: Node3D
@export var interaction_area: Area3D
@export var pickup_time: float = 1.0
@export var throw_force: float = 15.0
@export var folllow_speed: float = 25.0
@export var follow_distance: float = 1.5
@export var max_interaction_distance: float = 5.0
var drop: bool = false
var object: BaseItem = null

@export var can_pick_up: bool = true


# MOVEMENT
@export_category("Movement")
@export_group("Basic Movement")
@export var walk_spd: float = 7.0 #speed on ground
@export var air_spd: float = 7.5 #speed in air
var spd: float #current speed
var def_spd_mult: float = 1.0
var spd_mult: float = def_spd_mult

@export var accel: float = 7.5 #acceleration multiplier on ground
@export var deccel: float = 10.0 #friction multiplier
@export var air_deccel: float = 0.5 #friction multiplier in air

@export var knockback_timer: Timer
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

@export_group("Climbing")
@export var climb_spd: float = 6.25
var current_ladder: Area3D = null
var was_climbing: bool = false

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


# ANIMATION, AUDIO, & VISUAL
@export_category("AAV")
@export_group("Animation")
@export var anim: AnimationPlayer

@export_group("Audio")
@export var audio_listener: AudioListener3D

@export_group("Visual")
@export var meshes_to_hide: Array[VisualInstance3D]
@export var visibility_notifier: VisibleOnScreenNotifier3D

# MISCELLANEOUS
@export_category("Miscellaneous")
@export var coll: CollisionShape3D
@export var death_poof_scale: Vector3 = Vector3(0.3, 0.3, 0.3)

#debug shit
@export var can_display_debug: bool = false
@export var debug_label: Label


func display_debug():
	if !is_multiplayer_authority(): return
	if can_display_debug: debug_label.text = str(
		"name: ", self.name, "\n",
		"states: ", current_state.name, "\n",
		"vel", Vector3(snappedf(velocity.x, 0.5), snappedf(velocity.y, 0.5), snappedf(velocity.z, 0.5)), "\n",
		"vel length: ", snappedf(velocity.length(), 0.5), "\n",
		"spd: ", get_spd(), "\n",
		"can coyote: ", can_coyote, "\n",
		"last fall distance: ", str(roundf(last_fall_distance)), "\n",
		"elevation: ", str(roundf(global_position.y))
		
		)
	else: debug_label.text = ""

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority(): return
	#camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	def_cam_origin = camera.transform.origin
	
	#health
	hp = def_hp
	shield = def_shield
	
	#states
	change_state("default")

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	
	#mouse camera input
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens_h))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens_v))

func _process(delta: float) -> void:
	#debug
	display_debug()
	
	#toggle cameras when not the controller
	if is_multiplayer_authority():
		camera.current = true
	else:
		camera.current = false
	
	#controller camera input
	if is_multiplayer_authority():
		var look_dir := Input.get_vector("look left", "look right", "look up", "look down")
		rotate_y(-look_dir.x * controller_sens_h)
		pivot.rotate_x(-look_dir.y * controller_sens_v)
		
		#rotating the camera
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-60), deg_to_rad(90))
	
	handle_camera_shake(delta)
	
	#look at the camera
	if head_follow_camera:
		look_at_mod.target_node = $pivot/SpringArm3D/Camera3D/Marker3D.get_path()
		#else: look_at_mod.target_node = nav_target.camera.get_path()
	else:
		look_at_mod.target_node = ""
	
	#hide the player from itself
	if is_multiplayer_authority() and meshes_to_hide.front().get_layer_mask_value(1) == true:
		for i in meshes_to_hide:
			i.set_layer_mask_value(1, false)
			i.set_layer_mask_value(2, true)
	elif !is_multiplayer_authority() and meshes_to_hide.front().get_layer_mask_value(1) == false:
		for i in meshes_to_hide:
			i.set_layer_mask_value(1, true)
			i.set_layer_mask_value(2, false)
	
	# health
	handle_health()
	
	# states
	if current_state:
		current_state.handle_state(delta)
	
	handle_interaction()
	
	# audio
	if audio_listener:
		if is_multiplayer_authority() and !audio_listener.is_current(): audio_listener.make_current()
		elif !is_multiplayer_authority() and audio_listener.is_current(): audio_listener.clear_current()

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if knockback_timer.is_stopped():
		if !handle_ladder_movement(delta):
			handle_movement(delta)
	else:
		velocity = kb_velocity
	
	handle_fall_height()
	
	if use_navigation:
		if knockback_timer.is_stopped():
			handle_navigation_movement(delta)
		else:
			velocity = kb_velocity
	
	if !snap_up_stairs_check(delta):
		move_and_slide()
		snap_to_stairs_check()

func headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * headbob_freq) * headbob_amp
	pos.x = cos(time * headbob_freq / 2) * headbob_amp
	return pos

func camera_tilt(input_x, input_z, delta):
	if camera:
		#z axis tilt (left & right)
		camera.rotation.z = lerp(camera.rotation.z, -input_x * z_camera_tilt, 10 * delta)
		#x axis tilt (front & back)
		camera.rotation.x = lerp(camera.rotation.x, (-input_z - 5.0) * (x_camera_tilt * 3), 10 * delta)

func apply_camera_shake(strength: float, time: float):
	randomize()
	camera_shake_noise.seed = randi()
	camera_shake_noise.frequency = 2.0
	
	camera_shake_strength = strength
	camera_shake_time = time
	camera_shake_tick = 0.0

func handle_camera_shake(delta):
	if camera_shake_time > 0:
		camera_shake_tick += delta * camera_shake_tick_speed
		camera_shake_time -= delta
		
		camera.h_offset = camera_shake_noise.get_noise_2d(camera_shake_tick, 0) * camera_shake_strength
		camera.v_offset = camera_shake_noise.get_noise_2d(0, camera_shake_tick) * camera_shake_strength
		
		camera_shake_strength = max(camera_shake_strength - camera_shake_reduction_rate * delta, 0)
	else:
		camera.h_offset = lerp(camera.h_offset, 0.0, 10.5 * delta)
		camera.v_offset = lerp(camera.v_offset, 0.0, 10.5 * delta)

func get_cam() -> Camera3D:
	return camera

func handle_health():
	#health
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
		apply_camera_shake(1.25, 0.05)
		Input.start_joy_vibration(0, 0.5, 0.25, 0.25)
		
		#sfx_hit.play()
	
	if_timer = Timer.new()
	add_child(if_timer)
	if_timer.connect("timeout", func(): if_timer.queue_free())
	if_timer.start(if_time)

func die():
	dead = true
	#hurtbox.coll.disabled = true
	#var x = load("res://objects/explosion/explosion.tscn").instantiate()
	#x.poof = true
	#get_tree().current_scene.add_child(x)
	#x.global_position = global_position + Vector3(0, death_poof_scale.y, 0)
	#x.scale = death_poof_scale
	#visible = false
	#if !player: queue_free()

func change_state(new_state: String):
	# switches to the new state
	if current_state: current_state.exit_state(self)
	current_state = state_machine.get_node(new_state)
	if current_state: current_state.enter_state(self)

func handle_interaction():
	if !can_pick_up:
		if object: throw()
		return
	
	# item pick up
	if !object and interaction_area.has_overlapping_bodies():
		if interaction_area.get_overlapping_bodies().front() is BaseItem:
			var body = interaction_area.get_overlapping_bodies().front()
			body.pick_up(self)
			ui.display_text(str("PICKED UP ", body.item_name))
	
	if object: object.position = Vector3.ZERO
	
	#use item in hand
	if is_multiplayer_authority() and Input.is_action_just_pressed("interact"):
		if object and object.has_method("use"):
			object.use(self)
	
	#throw
	if is_multiplayer_authority() and Input.is_action_just_pressed("throw"):
		if object:
			throw()

func drop_object():
	object.position.x = -item_holder.position.x
	object.reparent(get_tree().current_scene, true)
	object.rotation_degrees = Vector3.ZERO
	object = null

func throw():
	interaction_area.get_child(0).disabled = true
	var obj = object
	drop_object()
	
	obj.throw(-camera.global_transform.basis.z * throw_force)
	await get_tree().create_timer(0.25).timeout
	interaction_area.get_child(0).disabled = false

func handle_movement(delta):
	if was_climbing: return
	
	#landing
	if is_on_floor(): land()
	
	if use_navigation: return
	
	#input
	if is_multiplayer_authority():
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#headbob & camera tilt
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = def_cam_origin + headbob(t_bob)
	
	camera_tilt(input_dir.x, -input_dir.y, delta)
	
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
	if Input.is_action_pressed("jump") and is_on_floor() and is_multiplayer_authority():
		velocity.y = jmp_vel
	
		#elevation
		elevation = global_position.y
		fall_distance = 0.0
		
		can_coyote = false
		if coyote_timer:
			coyote_timer.stop()
			coyote_timer = null
	
	#coyote jumping
	if Input.is_action_pressed("jump") and !is_on_floor() and is_multiplayer_authority():
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
			apply_camera_shake(0.5, 0.25)
		
		if fall_distance >= min_fall_height and take_fall_damage and !ignore_fall_damage:
			apply_damage(roundf(fall_dmg * (fall_distance - min_fall_height)), true)
		last_fall_distance = fall_distance
	
	fall_distance = 0
	
	on_floor_last_frame = Engine.get_physics_frames()
	can_coyote = true

func apply_knockback(direction: Vector3, force: float, duration: float = 0.25):
	if force == 0: return
	kb_velocity = direction * force
	knockback_timer.start(duration)

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

func handle_ladder_movement(delta) -> bool:
	# Keep track of whether already on ladder. If not already, check if overlapping a ladder area3d.
	was_climbing = current_ladder and current_ladder.overlaps_body(self)
	if !was_climbing:
		current_ladder = null
		for ladder in get_tree().get_nodes_in_group("ladder"):
			if ladder.overlaps_body(self):
				current_ladder = ladder
				break
	if current_ladder == null:
		return false
	
	var ladder_transform: Transform3D = current_ladder.global_transform
	var pos_rel_to_ladder := ladder_transform.affine_inverse() * self.global_position
	
	var forward_move
	var side_move
	if is_multiplayer_authority():
		forward_move = Input.get_action_strength("forward") - Input.get_action_strength("backward")
		side_move = Input.get_action_strength("right") - Input.get_action_strength("left")
	else: if use_navigation:
		forward_move = nav_dir.y
		side_move = nav_dir.x
	
	var ladder_forward_move
	var ladder_side_move
	if !use_navigation:
		ladder_forward_move = ladder_transform.affine_inverse().basis * get_cam().global_transform.basis * Vector3(0, 0, -forward_move)
		ladder_side_move = ladder_transform.affine_inverse().basis * get_cam().global_transform.basis * Vector3(side_move, 0, 0)
		#print(ladder_forward_move, ladder_side_move)
	else:
		ladder_forward_move = Vector3(0, 0, -1)
		ladder_side_move = Vector3.ZERO
	
	# Strafe velocity is simple. Just take x component rel to ladder of both
	var ladder_strafe_vel : float = climb_spd * (ladder_side_move.x + ladder_forward_move.x)
	# For climb velocity, there are a few things to take into account:
	# If strafing directly into the ladder, go up, if strafing away, go down
	var ladder_climb_vel : float = climb_spd * -ladder_side_move.z
	# When pressing forward & facing the ladder, the player likely wants to move up. Vice versa with down.
	# So we will bias the direction (up/down) towards where we are looking by 45 degrees to give a greater margin for up/down detect.
	var up_wish := Vector3.UP.rotated(Vector3(1,0,0), deg_to_rad(-45)).dot(ladder_forward_move)
	ladder_climb_vel += climb_spd * up_wish
	
	# Only begin climbing ladders when moving towards them & prevent sticking to top of ladder when dismounting
	# Trying to best match the player's intention when climbing on ladder
	var should_dismount = false
	if !was_climbing:
		var mounting_from_top = pos_rel_to_ladder.y > current_ladder.get_node("top of ladder").position.y
		if mounting_from_top:
			# They could be trying to get on from the top of the ladder, or trying to leave the ladder.
			if ladder_climb_vel > 0 and !use_navigation: should_dismount = true
			elif use_navigation:
				should_dismount = true
		else:
			# If not mounting from top, they are either falling or on floor.
			# In which case, only stick to ladder if intentionally moving towards
			if (ladder_transform.affine_inverse().basis * dir).z >= 0 and !use_navigation: should_dismount = true
		# Only stick to ladder if very close. Helps make it easier to get off top & prevents camera jitter
		if abs(pos_rel_to_ladder.z) > 0.5 and !use_navigation: should_dismount = true
	
	# Let player step off onto floor
	if is_on_floor() and ladder_climb_vel <= 0: should_dismount = true
	
	if should_dismount:
		current_ladder = null
		return false
	
	# Allow jump off ladder mid climb
	if was_climbing:
		if is_multiplayer_authority() and Input.is_action_just_pressed("jump"):
			#self.velocity = current_ladder.global_transform.basis.z * jmp_vel * 0.5
			self.velocity = self.global_transform.basis.z * jmp_vel * 0.5
			current_ladder = null
			return false
	
	self.velocity = ladder_transform.basis * Vector3(ladder_strafe_vel, ladder_climb_vel, 0)
	#self.velocity = self.velocity.limit_length(climb_speed) # Uncomment to turn off ladder boosting
	
	# Snap player onto ladder
	pos_rel_to_ladder.z = 0
	self.global_position = ladder_transform * pos_rel_to_ladder
	
	return true

func get_spd() -> float:
	if is_on_floor(): return walk_spd * spd_mult
	else: return air_spd * spd_mult

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
