extends EnemyState


func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	#super()
	if anim_override: return
	#if o.dead: return
	
	# base movement animations
	if !o.velocity:
		match o.facing:
			0:
				o.anim.play("idle")
			1, 2:
				o.anim.play("idle s")
			3:
				o.anim.play("idle b")

func exit_state(owner_node):
	super(exit_state)
