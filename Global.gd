extends Node


func spawn(scene: BaseController, target, amount = 1):
	for i in amount:
		var s = scene.duplicate()
		
		var timer = Timer.new()
		get_tree().current_scene.add_child(timer)
		timer.start(1.0)
		
		var r_pos: Vector3 = Vector3(randi_range(-10, 10), 0, randi_range(-10, 10))
		
		var ind = load("res://UI/spawning/spawn_indicator.tscn").instantiate()
		get_tree().current_scene.add_child(ind)
		ind.global_position = r_pos
		
		await timer.timeout
		timer.queue_free()
		ind.queue_free()
		
		if scene == null: return
		get_tree().current_scene.add_child(s)
		s.global_position = r_pos
		#s.nav_target = player_controller
		s.use_navigation = true

func indicate(text: String, position: Vector3, color: Color, outline_color: Color):
	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	label.shaded = true
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	label.font = load("res://UI/fonts/ThaleahFat.ttf")
	label.font_size = 16
	label.text = str(text)
	label.modulate = color
	label.outline_modulate = outline_color
	
	get_tree().current_scene.add_child(label)
	
	label.global_position = position
	label.scale = Vector3(5, 5, 5)
	
	await get_tree().create_timer(0.1).timeout
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 1, 1.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "scale", Vector3.ZERO, 0.5).set_ease(Tween.EASE_IN)
	
	await tween.finished
	label.queue_free()
