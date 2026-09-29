extends BaseEnemy
class_name Badman


func _on_i_got_a_booboo_to_t() -> void:
	change_state("hit")
