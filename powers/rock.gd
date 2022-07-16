extends Node2D

const DIE_TIME: float = .5


func _on_area_2d_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("damage"):
		parent.damage(2)
		$Area2D.queue_free()
		_die()


func _die():
	var twn = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	
	twn.tween_property(self, "scale", Vector2(2, 2), DIE_TIME)
	twn.tween_property(self, "modulate", Color(1, 1, 1, 0), DIE_TIME)
	await twn.finished
	queue_free()
