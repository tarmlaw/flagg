extends State

@onready var timer: Timer = $Timer
var time: float = 0.2

@onready var hitbox: Hitbox = $hitbox


func enter_state(owner_node):
	super(owner_node)
	timer.start(time)
	match o.facing:
		0:
			o.anim.play("basic")
			o.silly_anim.play("basic")
		1, 2:
			o.anim.play("basic s")
			o.silly_anim.play("basic s")
		3:
			o.anim.play("basic b")
			o.silly_anim.play("basic b")
	
	hitbox.coll.disabled = false

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)
	hitbox.coll.disabled = true

func _on_timer_timeout() -> void:
	o.change_state("default")
