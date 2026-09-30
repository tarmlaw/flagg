extends BaseClass
class_name Goblin

## CAMERA & UI
#@export_category("Camera & UI")

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

## NAVIGATION
#@export_category("Navigation")

## ANIMATION, AUDIO, & VISUAL
#@export_category("AAV")

## MISCELLANEOUS
#@export_category("Miscellaneous")

@onready var hp_label: Label3D = $Label3D


func display_debug():
	#display hp for other players
	if !is_multiplayer_authority():
		hp_label.text = str("HP: ", hp, " SHIELD: ", shield)
	else:
		hp_label.text = ""
	
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
	#super()

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

func apply_damage(damage, ignore_shield: bool = false):
	super(damage, ignore_shield)

func die():
	super()

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

func handle_fall_height():
	super()

func land(ignore_fall_damage: bool = false):
	super(ignore_fall_damage)

func apply_knockback(direction: Vector3, force: float, duration: float = 0.1):
	super(direction, force, duration)

#func is_surface_too_steep(normal : Vector3) -> bool:
	#super(normal)

#func run_body_test_motion(from : Transform3D, motion : Vector3, result = null) -> bool:
	#super(from, motion, result)

func snap_to_stairs_check():
	super()

#func snap_up_stairs_check(delta) -> bool:
	#super(delta)

#func handle_ladder_movement(delta) -> bool:
	#super(delta)

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

#func get_nav_target():
	#super()
