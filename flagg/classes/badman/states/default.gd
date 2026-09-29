extends BadmanState


func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return
	
	if o.nav_target is Stickman:
		if o.nav_target.current_state.name == "punch" and o.nav_distance <= 5 and o.nav_distance > 3:
			var r = randi_range(1, 4)
			if r > 1: return
			o.change_state("block")

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)

func _on_navigation_agent_3d_target_reached() -> void:
	#allow movement and turning
	
	#when reached target, stop movement and turning, punch, then allow movement and turning
	o.change_state("punch")
	
	#when player punches and too far, stop movement, dodge, allow movement
	
	#when player punches and close enough, stop movement, block, stop turning, punch, allow movement and turning
