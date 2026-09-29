extends GooseState

var anim: AnimationPlayer

func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	if o.dead: return
	
	if Input.is_action_just_pressed("main"):
		o.change_state("flap")

func handle_animation():
	super()
	
	if !o.velocity: o.anim.play("goose/idle")
	else: o.anim.play("goose/waddle", -1, o.spd_mult)

func exit_state(owner_node):
	super(exit_state)
