extends BaseItem
class_name Flag

var user


func pick_up(picked_up_by):
	super(picked_up_by)
	picked_up_by.status_effect_handler.inflict_beacon(1)
	user = picked_up_by

#func use(controller: Node3D):
	#super(controller)

func throw(throw_dir: Vector3):
	super(throw_dir)
	user.status_effect_handler.inflict_beacon(2)
	user = null
