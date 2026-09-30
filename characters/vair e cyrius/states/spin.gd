extends State

@onready var cd_timer: Timer = $CDTimer
var cd: float = 0.25


func enter_state(owner_node):
	super(owner_node)
	cd_timer.start(cd)

func handle_state(_delta):
	super(handle_state)
	o.hurtbox.coll.disabled = true
	
	# "spin" enemies
	for e in o.spin_area.get_overlapping_bodies():
		if e.has_method("get_silly"):
			if e.spinned == false: e.get_silly()

func handle_animation():
	super()
	o.anim.play("spin")
	o.silly_anim.play("spin")

func exit_state(owner_node):
	super(exit_state)
	o.silly = !o.silly
	o.hurtbox.coll.disabled = false

func _on_cd_timer_timeout() -> void:
	o.change_state("default")
