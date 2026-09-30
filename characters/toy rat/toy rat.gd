extends BaseController


## CAMERA & UI
#@export_category("Camera & UI")
#@export_group("Camera")

#@export_subgroup("Sensitivity")

#@export_subgroup("Camera Tilt")

#@export_subgroup("Headbob")

#@export_subgroup("Camera Shake", "camera")

#@export_subgroup("Miscellaneous")


## HEALTH
#@export_category("Health")
#@export_group("Health")


## STATUS EFFECTS


## STATES
#@export_category("States")


## INTERACTION
#@export_category("Interaction")
#@export_group("Interaction")


## MOVEMENT
#@export_category("Movement")
#@export_group("Basic Movement")

#@export_group("Slopes & Stairs")

#@export_group("Climbing")

#@export_group("Jumping & Gravity")
#@export_subgroup("Basic Jumping & Gravity")

#@export_subgroup("Coyote Jump")

#@export_subgroup("Elevation & Fall Damage")


## NAVIGATION
#@export_category("Navigation")


# MISCELLANEOUS
@export_category("Miscellaneous")
@export var spinned: bool = false
@onready var explosion_timer: Timer = $ExplosionTimer
@export var explosion_time: float = 1.0


func _enter_tree() -> void:
	super()

func _ready() -> void:
	super()

func _input(event: InputEvent) -> void:
	super(event)

func _process(delta: float) -> void:
	super(delta)

func _physics_process(delta: float) -> void:
	super(delta)

#func headbob(time) -> Vector3:
	#super(time)

func camera_tilt(input_x, input_z, delta):
	super(input_x, input_z, delta)

func apply_camera_shake(strength: float, time: float):
	super(strength, time)

func handle_camera_shake(delta):
	super(delta)

#func get_cam() -> Camera3D:
	#super()

func handle_health():
	super()

func apply_damage(damage):
	super(damage)

func die():
	super()
	var e = load("res://objects/explosion/explosion.tscn").instantiate()
	get_tree().current_scene.add_child(e)
	e.global_position = global_position + Vector3(0, 0.5, 0)

func change_state(new_state: String):
	super(new_state)

func handle_interaction():
	super()

func drop_object():
	super()

func throw():
	super()

func handle_movement(delta):
	super(delta)

func apply_knockback(direction: Vector3, force: float, duration: float = 0.1):
	super(direction, force, duration)

#stair/ladder shit i copied
#func is_surface_too_steep(normal : Vector3) -> bool:
	#super()

#func run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	#super()

func snap_to_stairs_check():
	super()

#func snap_up_stairs_check(delta) -> bool:
	#super()

#func handle_ladder_movement(delta) -> bool:
	#super()

#func get_spd() -> float:
	#super()

#func get_accel() -> float:
	#super()

#func get_deccel() -> float:
	#super()

#func get_grv() -> float:
	#super()

func handle_navigation_movement(delta):
	super(delta)

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	super(safe_velocity)

func get_nav_target():
	super()

func handle_facing():
	super()

func get_silly():
	if explosion_timer.is_stopped():
		spd_mult += 3.0
		explosion_timer.start(explosion_time)

func _on_explosion_timer_timeout() -> void:
	can_move = false
	use_navigation = false
	#await get_tree().create_timer(0.25).timeout
	die()
