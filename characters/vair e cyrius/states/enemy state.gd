extends Node
class_name EnemyState

var o #owner
var active: bool = false

@export var movement_override: bool = false
@export var anim_override: bool = false
@export var spd_mult: float = 0.0
@export var ignore_grv: bool = false

@export_group("Projectile")
@export var projectile: PackedScene
@export var count: int = 1
@export var arc: float = 0.0
@export var rate: float = 1.0
@export var max_spread: int = 1
@export var projectile_position: Vector3
@export var projectile_timer: Timer
@export var projectile_marker: Marker3D
@export var projectile_shake_strength: float = 0.5
@export var projectile_shake_time: float = 0.1


func enter_state(owner_node):
	o = owner_node
	o.spd_mult += spd_mult
	o.ignore_grv = ignore_grv

func handle_state(_delta):
	if movement_override: o.can_move = false
	else: o.can_move = true
	
	handle_animation()

func handle_animation():
	if anim_override: return
	#if o.dead: return
	
	# base movement animations
	if !o.velocity:
		match o.facing:
			0:
				o.anim.play("idle")
			1, 2:
				o.anim.play("idle s")
			3:
				o.anim.play("idle b")
	else:
		match o.facing:
			0:
				o.anim.play("run")
			1, 2:
				o.anim.play("run s")
			3:
				o.anim.play("run b")

func shoot():
	if projectile_timer.is_stopped():
		projectile_timer.start(rate)
		
		for i in count:
			var p = projectile.instantiate()
			
			get_tree().current_scene.add_child(p)
			p.global_position = projectile_marker.global_position
			
			p.look_at(o.nav_target.global_position)
			
			if count > 1:
				var arc_rad = deg_to_rad(arc)
				var inc = arc_rad / (count - 1)
				p.global_rotation.y = (p.global_rotation.y + inc * i - arc_rad / 2)

func exit_state(owner_node):
	o.spd_mult -= spd_mult
	o.ignore_grv = false
