extends Node2D

const INIT_DELAY = 0.2
const FLY_TIME = 0.2


func fly_to(enemy: Node2D) -> void:
	await get_tree().create_timer(INIT_DELAY).timeout
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	
	if is_instance_valid(enemy):
		tween.tween_property(self, "position", Vector2(enemy.get_absolute_pos()), FLY_TIME)
		enemy.damage(3)
	await tween.finished
	queue_free()
