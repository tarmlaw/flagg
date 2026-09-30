extends Node
class_name GoblinState

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
@export var projectile_position: Vector2
@export var projectile_timer: Timer
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
		o.anim.play("goblin_anim/idle")
	else:
		o.anim.play("goblin_anim/run")

func shoot():
	if projectile_timer.is_stopped():
		projectile_timer.start(rate)
		var origin_rotation
		
		if is_equal_approx(o.shoot_ray.rotation_degrees, -90):
			projectile_position = Vector2(2, -13)
			origin_rotation = deg_to_rad(-90)
		
		elif is_equal_approx(o.shoot_ray.rotation_degrees, 90):
			projectile_position = Vector2(5, 7)
			origin_rotation = deg_to_rad(90)
		
		else:
			projectile_position = Vector2(12, -4)
			if !o.flipped: origin_rotation = deg_to_rad(0)
			else: origin_rotation = deg_to_rad(180)
			
		if !o.flipped: projectile_position.x = abs(projectile_position.x)
		else: projectile_position.x = -abs(projectile_position.x)
		
		for i in count:
			var p = projectile.instantiate()
			
			if count == 1:
				p.rotation_degrees = origin_rotation
			else:
				var arc_rad = deg_to_rad(arc)
				var inc = arc_rad / (count - 1)
				p.rotation_degrees = (origin_rotation + inc * i - arc_rad / 2)
			
			p.global_position = o.global_position + projectile_position
			p.global_position.y += randi_range(-max_spread, max_spread)
			
			p.use_enemy_collision_layers = false
			
			get_tree().current_scene.add_child(p)
			p.flipped = o.flipped
			
			#o.sfx_shoot.play()
			o.apply_camera_shake(projectile_shake_strength, projectile_shake_time)
			Input.start_joy_vibration(0, 1.0, 0.25, 0.25)

func exit_state(owner_node):
	o.spd_mult -= spd_mult
	o.ignore_grv = false
