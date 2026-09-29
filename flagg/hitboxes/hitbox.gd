extends Area3D
class_name Hitbox

@onready var punch: AudioStreamPlayer3D = $punch


@onready var coll: CollisionShape3D = $CollisionShape3D
@export var dmg: int = 0
@export var kb: float = 0
@export var rumble: bool = false
@export var weak_rumble: float = 0.5
@export var strong_rumble: float = 0.5
@export var rumble_time: float = 0.2

@export var state: Node3D

@export_category("Timing")
@onready var start_timer: Timer = $StartTimer
@onready var end_timer: Timer = $EndTimer
@export var start_time: float = 0.1 ## how long until the hitbox activates
@export var end_time: float = 1.0 ## how long until the hitbox deactivates
@export var always_on: bool = true

signal hit_something(hurtbox: Hurtbox)


func _ready() -> void:
	if !always_on:
		coll.disabled = true
		if state == null: state = get_state()
		if state.has_signal("state_entered"):
			state.connect("state_entered", enter_state)
			state.connect("state_exited", exit_state)

func _process(delta: float) -> void:
	if state == null and !always_on:
		state = get_state()
		if state.has_signal("state_entered"):
			state.connect("state_entered", enter_state)
			state.connect("state_exited", exit_state)

func enter_state():
	coll.disabled = true
	if !always_on:
		start_timer.start(start_time)
		end_timer.start(end_time)
	else:
		coll.disabled = false

func exit_state():
	start_timer.stop()
	end_timer.stop()
	coll.disabled = true

func _on_start_timer_timeout() -> void:
	coll.disabled = false

func _on_end_timer_timeout() -> void:
	coll.disabled = true

func get_state() -> Node3D:
	return get_parent()


func _on_hit_something(hurtbox: Hurtbox) -> void:
	if rumble:
		Input.start_joy_vibration(0, weak_rumble, strong_rumble, rumble_time)
		punch.play()
