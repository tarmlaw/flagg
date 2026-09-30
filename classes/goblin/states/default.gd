extends GoblinState

func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)
