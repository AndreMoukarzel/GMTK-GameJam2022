extends Node2D

const INIT_DELAY = 0.2
const FLY_TIME = 0.5


func fly_to(enemy: Node2D, target_pos: Vector2i) -> void:
	await get_tree().create_timer(INIT_DELAY).timeout
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	
	tween.tween_property(self, "position", Vector2(target_pos), FLY_TIME)
	await tween.finished
	if is_instance_valid(enemy):
		enemy.freeze_fx()
		enemy.damage(1)
	queue_free()
