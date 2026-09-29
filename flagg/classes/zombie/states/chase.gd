extends ZombieState


var sight_timer: Timer


func enter_state(owner_node):
	super(owner_node)
	if sight_timer: sight_timer.queue_free()
	sight_timer = Timer.new()
	sight_timer.wait_time = 5.0
	sight_timer.one_shot = true
	add_child(sight_timer)
	sight_timer.connect("timeout", func(): o.change_state("default"))

func handle_state(_delta):
	super(handle_state)
	if !sight_timer: return
	
	if !o.target_in_sight() and sight_timer.is_stopped():
		sight_timer.start()
	if o.target_in_sight(): sight_timer.stop()

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)

func _on_navigation_agent_3d_target_reached() -> void:
	pass
