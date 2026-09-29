extends BaseClass
class_name Goose


@onready var hp_label: Label3D = $Label3D


func display_debug():
	#display hp for other players
	hp_label.text = str("HP: ", hp, " SHIELD: ", shield)
	
	super()

func _enter_tree() -> void:
	super()
	Global.player = self

func _exit_tree() -> void:
	Global.player = null

func _ready() -> void:
	super()

func _input(event: InputEvent) -> void:
	super(event)

func _process(delta: float) -> void:
	super(delta)
	#print(current_state.name)
	
	#if item_holder.get_child_count() > 0: hand_anim.visible = false
	#else: hand_anim.visible = true

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
	#ui.healthbar.max_value = max_hp * 50
	#ui.healthbar.value = hp * 50

func apply_damage(damage, ignore_shield: bool = false, ignore_shake: bool = false):
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

func apply_knockback(direction: Vector3, force: float, duration: float = 0.15):
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
