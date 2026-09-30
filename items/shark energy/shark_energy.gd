extends BaseItem
class_name SharkEnergy


func use(controller: Node3D):
	if controller.hp == controller.max_hp: return
	if controller.hp >= controller.max_hp - (controller.decay * 2): return
	
	super(controller)
	controller.apply_healing(2)
	controller.status_effect_handler.inflict_speed(2)
