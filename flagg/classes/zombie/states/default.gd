extends ZombieState


func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	if o.target_in_sight(): o.change_state("chase")

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)

func _on_navigation_agent_3d_target_reached() -> void:
	pass
