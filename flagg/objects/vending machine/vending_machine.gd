extends StaticBody3D

@onready var if_timer: Timer = $IFTimer
@export var if_time: float = 0.1
@onready var spawn_pos: Marker3D = $"spawn pos"


func apply_damage(_damage: float):
	if !if_timer.is_stopped(): return
	
	dispense()
	#sfx_hit.play()
	
	if_timer.start(if_time)

func dispense():
	var shark = load("res://items/shark energy/shark energy.tscn").instantiate()
	get_tree().current_scene.add_child(shark)
	shark.global_position = spawn_pos.global_position
