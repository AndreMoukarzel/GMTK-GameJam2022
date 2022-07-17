extends Node2D


var duration: int = 3
var GameLevel
var my_pos


func grow(pos: Vector2i, pos_modifier: int, obstacles: Array):
	if pos in obstacles:
		queue_free()
	
	GameLevel = get_parent().get_parent()
	
	if pos.x > 0 and pos.y > 0 and pos.x <= GameLevel.MAP_SIZE.x and pos.y <= GameLevel.MAP_SIZE.y:
		global_position = pos * pos_modifier
		GameLevel.obstacles.append(pos)
		my_pos = pos
	else:
		queue_free()


func act(_player_pos: Vector2i, _obstacles: Array):
	duration -= 1
	if duration <= 0:
		GameLevel.obstacles.remove_at(GameLevel.obstacles.find(my_pos))
		$AnimationPlayer.play("die")
		await $AnimationPlayer.animation_finished
		queue_free()
