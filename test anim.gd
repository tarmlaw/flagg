extends AnimatedSprite3D

var facing
@export var p: CharacterBody3D

func _process(delta: float) -> void:
	if p == null: return
	var cam = p.tps_camera
	
	var cam_fwd = cam.global_transform.basis.z
	var fwd = global_transform.basis.z
	var left = global_transform.basis.x
	var fdot = fwd.dot(cam_fwd)
	var ldot = left.dot(cam_fwd)
	
	print(facing)
	
	if fdot < -2.5:
		facing = 0
	elif fdot > 2.5:
		facing = 3
	else:
		if ldot < 0:
			flip_h = true
			facing = 2
		if ldot > 0:
			flip_h = false
			facing = 1
	
	match facing:
		0: play("idle")
		1, 2:
			play("idle s")
		3:
			play("idle b")
