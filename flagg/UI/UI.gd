extends CanvasLayer


var p: BaseClass = null

@onready var interaction_label: Label = $InteractionLabel

@onready var bloodoverlay: TextureRect = $bloodoverlay


#@onready var healthbar_hbox: HBoxContainer = $HBoxContainer
#@onready var healthbar_hbox2: HBoxContainer = $HBoxContainer/healthbar2
#@onready var heart_scene = preload("res://UI/assets/heart.tscn")

#@onready var font: FontFile = preload("res://fonts/LazyFox Pixel Font 3.ttf")
#@onready var healthbar: TextureProgressBar = $TextureProgressBar


func _ready() -> void:
	interaction_label.text = ""

func _process(delta: float) -> void:
	if p == null: p = get_parent()
	
	visible = true
	
	if interaction_label.text == "": interaction_label.visible = false
	else: interaction_label.visible = true
	
	bloodoverlay.modulate.a = (p.max_hp - p.hp) * 0.1
	
	if p.interaction_ray:
		if p.interaction_ray.is_colliding(): interaction_label.text = p.interaction_ray.get_collider().item_name
		else: interaction_label.text = ""
	else: interaction_label.text = ""
	
	#if !p.is_connected("i_got_a_booboo_ToT", display_health):
		#p.connect("i_got_a_booboo_ToT", display_health)
	#if !p.is_connected("health_changed", display_health):
		#p.connect("health_changed", display_health)
	
	#if healthbar_hbox.get_child(0).get_child_count() == 0: display_health()

#func display_health():
	##reset all values
	#var healthbar = healthbar_hbox.get_child(0)
	#var shieldbar = healthbar_hbox.get_child(1)
	#var hp_left: int = p.hp
	#var shield_left: int = p.shield
	#for i in healthbar.get_children(): healthbar.remove_child(i)
	#for i in shieldbar.get_children(): shieldbar.remove_child(i)
	
	##display max hearts as empty
	#while healthbar.get_child_count() != p.max_hp / 2 + p.max_hp % 2:
		#var heart = heart_scene.instantiate()
		#var anim: AnimatedSprite2D = heart.get_child(0)
		#healthbar.add_child(heart)
		##assign values
		#if hp_left >= 2:
			#hp_left -= 2
			#anim.play("def 2")
		#elif hp_left == 1:
			#hp_left -= 1
			#anim.play("def 1")
		#else:
			#anim.play("0")
	
	##dont display empty shield hearts
	#while shieldbar.get_child_count() != p.shield / 2 + p.shield % 2:
		#var heart = heart_scene.instantiate()
		#var anim: AnimatedSprite2D = heart.get_child(0)
		#shieldbar.add_child(heart)
		##assign values
		#if shield_left >= 2:
			#shield_left -= 2
			#anim.play("shield 2")
		#elif shield_left == 1:
			#shield_left -= 1
			#anim.play("shield 1")
	#
	##display decayed hearts
	#if p.decay > 0:
		#var hearts: Array = healthbar.get_children()
		#var heart_idx: int = 0
		#
		##only show decayed hearts
		##if decay is 1 and max hp is 5, only display hearts 3 to 4 (max - 1)
		#for i in hearts:
			#if hearts.find(i) >= (roundi(p.max_hp / 2) - p.decay):
				##set value
				#match i.get_child(0).get_animation():
					#"def 1":
						#i.get_child(0).play("decay 1")
					#"def 2":
						#i.get_child(0).play("decay 2")
					#_:
						#i.get_child(0).play("decay 0")
	#
	##update ui
	#update_healthbar()
	#update_healthbar()
#
#func update_healthbar():
	#if p.shield <= 0:
		#healthbar_hbox.pivot_offset.x = healthbar_hbox.get_child(0).size.x / 2
		#healthbar_hbox.position.x = 800 - healthbar_hbox.pivot_offset.x
		#healthbar_hbox.position.y = 768
	#else:
		#healthbar_hbox.pivot_offset.x = healthbar_hbox.size.x / 2
		#healthbar_hbox.position.x = 800 - healthbar_hbox.pivot_offset.x
		#healthbar_hbox.position.y = 768

func display_text(text: String, color: Color = Color("d6f264")):
	print(text)
	var label: Label = Label.new()
	label.theme = load("res://fonts/theme.tres")
	add_child(label)
	label.add_theme_color_override("font_color", color)
	#label.add_theme_font_override("font", font)
	#label.add_theme_font_size_override("font_size", 36)
	label.text = text
	label.name = text
	label.size = Vector2(320, 12)
	label.position = Vector2(0, 192)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	
	var tween = create_tween()
	var tween2 = create_tween()
	tween.tween_property(label, "position", Vector2(label.position.x, 120), 1.5)
	tween2.tween_property(label, "modulate", Color("ffffff00"), 1.5)
	tween2.connect("finished", func(): label.queue_free())
