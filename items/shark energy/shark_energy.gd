extends BaseItem
class_name SharkEnergy


func use(path):
	var p = get_node(path)
	
	if p.hp == p.max_hp: return
	if p.hp >= p.max_hp - (p.decay * 2): return
	
	super(path)
	p.apply_healing(2)
	p.status_effect_handler.inflict_speed(2)
