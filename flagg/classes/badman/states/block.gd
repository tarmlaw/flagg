extends BadmanState

@onready var hurtbox: Hurtbox = $"../../hurtbox"


func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return
	
	hurtbox.coll.disabled = true

func handle_animation():
	super()
	o.anim.play("block")

func exit_state(owner_node):
	super(exit_state)
	hurtbox.coll.disabled = false
