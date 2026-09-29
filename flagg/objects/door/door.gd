extends StaticBody3D
class_name Door


@export var item_name: String

@onready var anim: AnimationPlayer = $AnimationPlayer
@export var open: bool = false


func _ready() -> void:
	if open:
		anim.play("open", -1, 10)
	
	anim.connect("animation_finished", func(anim_name: StringName): open = !open)

func use():
	if open: anim.play("close")
	else: anim.play("open")
