extends EnemyState

@onready var throw_timer: Timer = $ThrowTimer
@export var throw_time: float = 1.0

func enter_state(owner_node):
	super(owner_node)
	throw_timer.start(throw_time)
	shoot()
	await get_tree().create_timer(rate).timeout
	o.change_state("default")

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	super()

func shoot():
	super()

func exit_state(owner_node):
	super(exit_state)
