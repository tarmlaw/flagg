extends State

@onready var spin_cd_timer: Timer = $"../spin/CDTimer"
@onready var ba_timer: Timer = $"../basic attack/Timer"
@onready var qa_timer: Timer = $"../quick attack/Timer"
@onready var da_timer: Timer = $"../downward attack/Timer"


func enter_state(owner_node):
	super(owner_node)

func handle_state(_delta):
	super(handle_state)
	#if o.dead: return
	
	if Input.is_action_just_pressed("spin") and o.input_dir and spin_cd_timer.is_stopped(): o.change_state("spin")
	
	if o.input_dir and o.is_on_floor():
		if Input.is_action_just_pressed("main") and ba_timer.is_stopped(): o.change_state("basic attack")
	elif !o.input_dir and o.is_on_floor():
		if Input.is_action_just_pressed("main") and ba_timer.is_stopped(): o.change_state("quick attack")
	if !o.is_on_floor():
		if Input.is_action_just_pressed("main") and ba_timer.is_stopped(): o.change_state("downward attack")

func handle_animation():
	super()

func exit_state(owner_node):
	super(exit_state)
