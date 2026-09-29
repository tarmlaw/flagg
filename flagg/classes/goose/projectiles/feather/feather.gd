extends BaseProjectile
class_name Feather


var dmg: int = 1

func _ready() -> void:
	hitbox.dmg = dmg
