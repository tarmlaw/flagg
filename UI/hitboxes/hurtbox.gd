extends Area3D
class_name Hurtbox

@export var target: Node3D = null

@onready var coll: CollisionShape3D = $CollisionShape3D
#@export var apply_knockback: bool = true

@export var status_effect_handler: StatusEffectHandler


func hurt(damage: int, ignore_shield: bool = false):
	if target == null: get_parent().apply_damage(damage, ignore_shield)
	else: target.apply_damage(damage, ignore_shield)

func _on_area_entered(area: Hitbox) -> void:
	area.hit_something.emit()
	
	if target == null:
		if get_parent().hp < 1: return
		get_parent().apply_damage(area.dmg)
		if get_parent().has_method("apply_knockback"): get_parent().apply_knockback(-global_position.direction_to(area.global_position), area.kb)
		Global.indicate(str(area.dmg), global_position + Vector3(randi_range(-0.5, 0.5), 1.25, randi_range(-0.5, 0.5)), Color.RED, Color.BLACK)
	
	else:
		if target.hp < 1: return
		target.apply_damage(area.dmg)
		if target.has_method("apply_knockback"): target.apply_knockback(-global_position.direction_to(area.global_position), area.kb)
		Global.indicate(str(area.dmg), global_position + Vector3(randi_range(-0.5, 0.5), 1.25, randi_range(-0.5, 0.5)), Color.RED, Color.BLACK)
	
	#if apply_knockback:
		#get_parent().apply_knockback(10, area.global_position)
	
	## PROJECTILES
	#if area.get_parent().is_in_group("projectile"):
		#area.get_parent().queue_free()
	
	## STATUS EFFECTS
	if status_effect_handler == null: return
	
	if area.bleed > 0: status_effect_handler.inflict_bleed(area.bleed)
	if area.decay > 0: status_effect_handler.inflict_decay(area.decay)
	if area.speed > 0: status_effect_handler.inflict_speed(area.speed)
	if area.slow > 0: status_effect_handler.inflict_slow(area.slow)
	if area.beacon > 0: status_effect_handler.inflict_beacon(area.beacon)
