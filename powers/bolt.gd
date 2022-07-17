extends Node2D

const INIT_DELAY = 0.2
const FLY_TIME = 0.2


func fly_to(enemy: Node2D, target_pos: Vector2i) -> void:
	await get_tree().create_timer(INIT_DELAY).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	
	tween.tween_property(self, "position", Vector2(target_pos), FLY_TIME)
	if is_instance_valid(enemy):
		enemy.damage(3)
	await tween.finished
	queue_free()
