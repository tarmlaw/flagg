extends CanvasLayer

var p: BaseClass = null

@onready var healthbar_hbox: HBoxContainer = $HBoxContainer
@onready var healthbar_hbox2: HBoxContainer = $HBoxContainer/healthbar2
@onready var heart_scene = preload("res://UI/assets/heart.tscn")

@onready var font: FontFile = preload("res://UI/fonts/dungeon-mode.ttf")
@onready var pivot: Node3D = $SubViewport/pivot
@onready var camera: Camera3D = $SubViewport/pivot/Camera3D


func _process(delta: float) -> void:
	if p == null: p = get_parent()
	
	if !p.is_multiplayer_authority(): visible = false
	else: visible = true
	
	if !p.is_connected("i_got_a_booboo_ToT", display_health):
		p.connect("i_got_a_booboo_ToT", display_health)
	if !p.is_connected("health_changed", display_health):
		p.connect("health_changed", display_health)
	
	if healthbar_hbox.get_child(0).get_child_count() == 0: display_health()
	
	pivot.global_position = p.global_position
	camera.look_at(p.pivot.global_position)
	

func display_health():
	#reset all values
	var healthbar = healthbar_hbox.get_child(0)
	var shieldbar = healthbar_hbox.get_child(1)
	var hp_left: int = p.hp
	var shield_left: int = p.shield
	for i in healthbar.get_children(): healthbar.remove_child(i)
	for i in shieldbar.get_children(): shieldbar.remove_child(i)
	
	#display max hearts as empty
	while healthbar.get_child_count() != p.max_hp / 2 + p.max_hp % 2:
		var heart = heart_scene.instantiate()
		var anim: AnimatedSprite2D = heart.get_child(0)
		healthbar.add_child(heart)
		#assign values
		if hp_left >= 2:
			hp_left -= 2
			anim.play("def 2")
		elif hp_left == 1:
			hp_left -= 1
			anim.play("def 1")
		else:
			anim.play("0")
	
	#dont display empty shield hearts
	while shieldbar.get_child_count() != p.shield / 2 + p.shield % 2:
		var heart = heart_scene.instantiate()
		var anim: AnimatedSprite2D = heart.get_child(0)
		shieldbar.add_child(heart)
		#assign values
		if shield_left >= 2:
			shield_left -= 2
			anim.play("shield 2")
		elif shield_left == 1:
			shield_left -= 1
			anim.play("shield 1")
	
	#display decayed hearts
	if p.decay > 0:
		var hearts: Array = healthbar.get_children()
		var heart_idx: int = 0
		
		#only show decayed hearts
		#if decay is 1 and max hp is 5, only display hearts 3 to 4 (max - 1)
		for i in hearts:
			if hearts.find(i) >= (roundi(p.max_hp / 2) - p.decay):
				#set value
				match i.get_child(0).get_animation():
					"def 1":
						i.get_child(0).play("decay 1")
					"def 2":
						i.get_child(0).play("decay 2")
					_:
						i.get_child(0).play("decay 0")
	
	#update ui
	update_healthbar()
	update_healthbar()

func update_healthbar():
	if p.shield <= 0:
		healthbar_hbox.pivot_offset.x = healthbar_hbox.get_child(0).size.x / 2
		healthbar_hbox.position.x = 800 - healthbar_hbox.pivot_offset.x
		healthbar_hbox.position.y = 768
	else:
		healthbar_hbox.pivot_offset.x = healthbar_hbox.size.x / 2
		healthbar_hbox.position.x = 800 - healthbar_hbox.pivot_offset.x
		healthbar_hbox.position.y = 768

func display_text(text: String, color: Color = Color("d6f264")):
	var label: Label = Label.new()
	add_child(label)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 36)
	label.text = text
	label.name = text
	label.size = Vector2(1600, 156)
	label.position = Vector2(0, 744)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	var tween = create_tween()
	var tween2 = create_tween()
	tween.tween_property(label, "position", Vector2(label.position.x, 675), 0.8)
	tween2.tween_property(label, "modulate", Color("ffffff00"), 0.8)
	tween2.connect("finished", func(): label.queue_free())
