extends Node3D

@export var spawns: Array[PackedScene]

var spawning: bool = false
var enemies_left: int = 0

var in_round: bool = false

@onready var phase_timer: Timer = $PhaseTimer

enum{
	none,
	moo,
	another,
	cheers
}
var event = none
@onready var texture_rect: TextureRect = $TextureRect
@onready var anim: AnimationPlayer = $AnimationPlayer

#player enters ring (area)
#keeping track of score enables

#loop start
#calls global spawn func
#keeps track of enemies in tree
#when all enemies die, event (fading pop up with tiny emoji)
#loop end


func _ready() -> void:
	Global.enemy_spawned.connect(func(): in_round = true)

func _process(delta: float) -> void:
	enemies_left = get_tree().get_nodes_in_group("enemy").size()
	
	if in_round:
		handle_round()

func _on_arena_start_body_entered(body: Node3D) -> void:
	if Global.round > 0: return
	
	start_round()

func start_round():
	in_round = false
	Global.round += 1
	Global.score += 100
	Global.stickman.ui.display_text("ROUND %s" % Global.round, Color.RED)
	
	await get_tree().create_timer(1.0).timeout
	
	if Global.round > 1: start_event()
	
	for i in Global.spawn_amount:
		var spawn = spawns.pick_random().instantiate()
		Global.spawn(spawn, Global.stickman)

func start_event():
	var r = randi_range(0, 3)
	event = r
	
	Engine.time_scale *= 1.025
	Global.stickman.hp += 10
	
	match event:
		none:
			Global.stickman.ui.display_text("nothing happend.", Color.WHITE)
			var banner = load("res://UI/event (nothing).png")
			texture_rect.texture = banner
		moo:
			Global.stickman.ui.display_text("its raining cows...slowly...", Color.DIM_GRAY)
			var banner = load("res://UI/event (moo).png")
			texture_rect.texture = banner
			
			var cow_timer = Timer.new()
			cow_timer.wait_time = 7
			cow_timer.autostart = true
			cow_timer.one_shot = false
			add_child(cow_timer)
			cow_timer.connect("timeout", spawn_cow)
			spawn_cow()
			
		another:
			Global.stickman.ui.display_text("the more the merrier", Color.DEEP_PINK)
			var banner = load("res://UI/event (another).png")
			texture_rect.texture = banner
			
			Global.spawn_amount += 1
		cheers:
			Global.stickman.ui.display_text("this one's on the house", Color.BLUE)
			var banner = load("res://UI/event (cheers).png")
			texture_rect.texture = banner
			
			spawn_shark()
	
	anim.play("event")

func spawn_cow():
	var cow = load("res://classes/cow/cow.tscn").instantiate()
	add_child(cow)
	cow.global_position = Vector3(randi_range(-8, 8), 18, randi_range(-8, 8))

func spawn_shark():
	var shark = load("res://items/shark energy/shark energy.tscn").instantiate()
	add_child(shark)
	shark.global_position = Vector3(randi_range(-8, 8), 18, randi_range(-8, 8))

func handle_round():
	if enemies_left <= 0 and phase_timer.is_stopped():
		phase_timer.start()
		start_round()
		return
