extends EnemyState


func enter_state(owner_node):
	super(owner_node)
	shoot()
	await get_tree().create_timer(rate).timeout
	o.change_state("default")

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	super()

func shoot():
	#super()
	if projectile_timer.is_stopped():
		projectile_timer.start(rate)
		
		for i in count:
			var p = projectile.instantiate()
			
			get_tree().current_scene.add_child(p)
			p.global_position = projectile_marker.global_position
			
			#p.look_at(o.nav_target.global_position)
			
			if count > 1:
				var arc_rad = deg_to_rad(arc)
				var inc = arc_rad / (count - 1)
				p.global_rotation.y = (p.global_rotation.y + inc * i - arc_rad / 2)

func exit_state(owner_node):
	super(exit_state)
