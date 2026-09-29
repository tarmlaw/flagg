extends Area3D
class_name Hurtbox

@export var target: Node3D = null

@onready var coll: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	get_target()

func _physics_process(_delta: float) -> void:
	if !monitoring: return
	
	if has_overlapping_areas():
		for area in get_overlapping_areas():
			if area is Hitbox:
				if area.is_in_group("constant pain"):
					area.hit_something.emit(self)
					if area.dmg > 0:
						get_target().apply_damage(area.dmg)

func hurt(damage: int):
	get_target().apply_damage(damage)

func get_target() -> Variant:
	if !target:
		target = get_parent()
	return target

func _on_area_entered(area: Area3D) -> void:
	#print("ack")
	if area is Hitbox:
		area.hit_something.emit(self)
		if area.dmg > 0 and get_target() is not BaseItem:
			get_target().apply_damage(area.dmg)
		
		if get_target() is BaseClass:
			get_target().apply_knockback(area.global_position.direction_to(get_target().global_position), area.kb)
		if get_target() is BaseItem:
			get_target().throw(-(area.global_position - get_target().global_position) * area.kb)
