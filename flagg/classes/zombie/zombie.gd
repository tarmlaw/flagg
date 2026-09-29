extends BaseEnemy
class_name Zombie


func _on_i_got_a_booboo_to_t() -> void:
	change_state("hit")


func _on_interaction_area_3d_body_entered(body: Node3D) -> void:
	if body is Door:
		if body.open: return
		body.use()
