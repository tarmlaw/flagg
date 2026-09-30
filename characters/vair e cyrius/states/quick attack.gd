extends State

@onready var timer: Timer = $Timer
var time: float = 0.15

@onready var hitbox: Hitbox = $hitbox


func enter_state(owner_node):
	super(owner_node)
	timer.start(time)
	match o.facing:
		0:
			o.anim.play("quick")
			o.silly_anim.play("quick")
		1, 2:
			o.anim.play("quick s")
			o.silly_anim.play("quick s")
		3:
			o.anim.play("quick b")
			o.silly_anim.play("quick b")
	
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
