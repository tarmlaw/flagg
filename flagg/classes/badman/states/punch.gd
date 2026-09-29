extends BadmanState

@onready var hitbox: Hitbox = $hitbox


func enter_state(owner_node):
	super(owner_node)
	o.anim.play("punch")
	
	hitbox.dmg = 2 + Global.round

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)

func _on_navigation_agent_3d_target_reached() -> void:
	pass
	#allow movement and turning
	#when reached target, stop movement and turning, punch, then allow movement and turning
	#when player punches and too far, stop movement, dodge, allow movement
	#when player punches and close enough, stop movement, block, stop turning, punch, allow movement and turning
