extends Node3D
class_name StatusEffectHandler

@export var hurtbox: Hurtbox

#hitbox has effect enabled
#hurtbox gets effects from hitbox and sends them to handler
#handler handlers effects wth the player controller

var bleed_timer: Timer = null
var bleed: bool = false
var bleed_left: int = 0

#decay takes a number of hearts and prevents them from being healed for some time
var decay_timer: Timer = null
var decay: bool = false

var speed_timer: Timer = null
var speed: bool = false
var spd_mult: float = 0.0

var slow_timer: Timer = null
var slow: bool = false
var slow_mult: float = 0.0

var beacon: int = 0


func _process(delta: float) -> void:
	if !get_parent().is_multiplayer_authority(): return
	#if Input.is_action_just_pressed("debug"):
		#inflict_decay(1)
	
	if get_child_count() > 1:
		get_child(1).rotation_degrees.y += (1 * get_process_delta_time() * 50)

func inflict_bleed(level: int = 1):
	if bleed: return
	bleed = true
	level = clampi(level, 1, 5)
	bleed_left = level * 2
	
	get_parent().ui.display_text("BLEEDING", Color("b4202a"))
	
	if !bleed_timer:
		bleed_timer = Timer.new()
		bleed_timer.wait_time = 1.0
		bleed_timer.one_shot = true
		bleed_timer.autostart = true
		
		add_child(bleed_timer)
		bleed_timer.timeout.connect(func():
			if bleed_left > 0:
				bleed_left -= 1
				hurtbox.hurt(1, true)
				bleed_timer.start()
			else:
				bleed = false
				bleed_timer.queue_free());

func inflict_decay(level: int = 1):
	if decay: return
	decay = true
	level = clampi(level, 1, 5)
	
	get_parent().ui.display_text("DECAY", Color("b4202a"))
	
	if !decay_timer:
		get_parent().decay = level
		get_parent().ui.display_health()
		
		decay_timer = Timer.new()
		decay_timer.wait_time = 15.0
		decay_timer.one_shot = true
		decay_timer.autostart = true
		add_child(decay_timer)
		decay_timer.timeout.connect(func():
			get_parent().decay -= level
			get_parent().ui.display_health()
			decay = false
			decay_timer.queue_free());

func inflict_speed(level: int = 1):
	if speed: return
	speed = true
	level = clampi(level, 1, 5)
	
	get_parent().ui.display_text("SPEED", Color("b4202a"))
	
	if !speed_timer:
		match level:
			1: spd_mult = 0.25
			2, 4: spd_mult = 0.5
			3, 5: spd_mult = 1.0
		get_parent().spd_mult += spd_mult
		
		speed_timer = Timer.new()
		match level:
			1, 2, 3: speed_timer.wait_time = 5.0
			4, 5: speed_timer.wait_time = 10.0
		speed_timer.one_shot = true
		speed_timer.autostart = true
		add_child(speed_timer)
		speed_timer.timeout.connect(func():
			get_parent().spd_mult -= spd_mult
			speed = false
			speed_timer.queue_free());

func inflict_slow(level: int = 1):
	if slow: return
	slow = true
	level = clampi(level, 1, 5)
	
	get_parent().ui.display_text("SLOW", Color("b4202a"))
	
	if !slow_timer:
		match level:
			1: slow_mult = -0.25
			2, 4: slow_mult = -0.5
			3, 5: slow_mult = -0.75
		get_parent().spd_mult += slow_mult
		
		slow_timer = Timer.new()
		match level:
			1, 2, 3: slow_timer.wait_time = 5.0
			4, 5: slow_timer.wait_time = 10.0
		slow_timer.one_shot = true
		slow_timer.autostart = true
		add_child(slow_timer)
		slow_timer.timeout.connect(func():
			get_parent().spd_mult -= slow_mult
			slow = false
			slow_timer.queue_free());

func inflict_beacon(level: int = 1):
	level = clampi(level, 1, 2)
	
	#get_parent().ui.display_text("BEACON", Color("b4202a"))
	
	match level:
		1:
			var beacon_mesh: MeshInstance3D = MeshInstance3D.new()
			var beacon_material: Material = load("res://UI/shaders/beacon.tres")
			beacon_mesh.mesh = BoxMesh.new()
			beacon_mesh.mesh.size = Vector3(1, 100, 1)
			beacon_mesh.mesh.surface_set_material(0, beacon_material)
		2:
			for i in get_children():
				if i.name == "beacon":
					i.queue_free()
