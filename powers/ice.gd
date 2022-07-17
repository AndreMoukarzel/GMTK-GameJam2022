extends Node2D


signal done

const INIT_DELAY = 0.2
const FLY_TIME = 0.5


func fly_to(enemy: Node2D) -> void:
	await get_tree().create_timer(INIT_DELAY).timeout
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	
	if is_instance_valid(enemy):
		tween.tween_property(self, "position", Vector2(enemy.get_absolute_pos()), FLY_TIME)
		await tween.finished
		enemy.freeze_fx()
	emit_signal("done")
	queue_free()
