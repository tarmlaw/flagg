extends Node2D

@onready var menu: Node2D = $menu
@onready var anim: AnimatedSprite2D = $anim
@onready var play: TextureButton = $menu/play
@onready var controls: TextureButton = $menu/controls
@onready var controls_2: Node2D = $menu/controls2

@onready var death: Node2D = $death
@onready var score: Label = $death/score


func _ready() -> void:
	play.grab_focus()
	
	score.text = str(Global.score)
	
	if !Global.game_over:
		menu.visible = true
		death.visible = false
	else:
		death.visible = true
		menu.visible = false
		await get_tree().create_timer(3.0).timeout
		Global.game_over = false
		Global.score = 0
		Global.round = 0
		Global.spawn_amount = 1
		Engine.time_scale = 1.0
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	anim.play("default")

func _on_play_pressed() -> void:
	controls_2.visible = false
	get_tree().change_scene_to_file("res://scenes/arena/arena.tscn")

func _on_controls_pressed() -> void:
	controls_2.visible = !controls_2.visible
