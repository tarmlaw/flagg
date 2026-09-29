extends Node

var player: BaseClass
var game_over: bool = false

var score: int = 0
var round: int = 0
var spawn_amount: int = 1

var main_camera: Camera3D = null

var portals: Array = []

signal enemy_spawned


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"): spawn(load("res://classes/zombie/zombie.tscn").instantiate(), player)
	
	
	#find main camera
	if player != null: main_camera = player.get_cam()
	
	#portal main camera
	for portal in portals:
		if portal.main_camera != main_camera:
			portal.main_camera = main_camera

func spawn(scene, target, spawn_pos: Vector3 = Vector3.ZERO, amount: int = 5):
	for i in amount:
		var s = scene.duplicate()
		await get_tree().create_timer(0.1).timeout
		#var timer = Timer.new()
		#get_tree().current_scene.add_child(timer)
		#timer.start(0.1)
		
		#var r_pos: Vector3 = Vector3(randi_range(-8, 8), 2, randi_range(-8, 8))
		
		#var ind = load("res://UI/spawning/spawn_indicator.tscn").instantiate()
		#get_tree().current_scene.add_child(ind)
		#ind.global_position = r_pos
		
		#await timer.timeout
		#timer.queue_free()
		#ind.queue_free()
		
		if scene == null: return
		get_tree().current_scene.add_child(s)
		s.global_position = spawn_pos
		#s.nav_target = player_controller
		s.use_navigation = true
	enemy_spawned.emit()

#func indicate(text: String, position: Vector3, color: Color, outline_color: Color):
	#var label = Label3D.new()
	#label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	#label.shaded = true
	#label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	#label.font = load("res://UI/fonts/ThaleahFat.ttf")
	#label.font_size = 16
	#label.text = str(text)
	#label.modulate = color
	#label.outline_modulate = outline_color
	#
	#get_tree().current_scene.add_child(label)
	#
	#label.global_position = position
	#label.scale = Vector3(5, 5, 5)
	#
	#await get_tree().create_timer(0.1).timeout
	#
	#var tween = get_tree().create_tween()
	#tween.set_parallel(true)
	#tween.tween_property(label, "position:y", position.y - 1, 1.0).set_ease(Tween.EASE_OUT)
	#tween.tween_property(label, "scale", Vector3.ZERO, 0.5).set_ease(Tween.EASE_IN)
	#
	#await tween.finished
	#label.queue_free()
