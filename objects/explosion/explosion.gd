extends AnimatedSprite3D

@onready var sfx_kaboom: AudioStreamPlayer3D = $KABOOM
@onready var hitbox: Hitbox = $hitbox
var poof: bool = false


func _ready() -> void:
	if !poof:
		play("KABOOM")
		Global.player_controller.apply_camera_shake(1.25, 0.25)
		Input.start_joy_vibration(0, 1.0, 1.0, 0.6)
		sfx_kaboom.play()
		hitbox.coll.disabled = false
	else:
		play("poof")
		#sfx_kaboom.play()
		hitbox.coll.disabled = true

func _on_animation_finished() -> void:
	visible = false
	hitbox.coll.disabled = true
	
	await sfx_kaboom.finished
	queue_free()
