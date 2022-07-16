extends Node2D


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3

@export_range(1, 5) var mov_num: int
var current_pos: Vector2i = Vector2i.ONE


func spawn(pos: Vector2i) -> void:
	current_pos = pos
	position = current_pos * MOV_DIST


func act(player_pos: Vector2i) -> void:
	for i in range(mov_num):
		var hor_diff = player_pos.x - current_pos.x
		var ver_diff = player_pos.y - current_pos.y
		var mov_tween
		
		if abs(hor_diff) > abs(ver_diff):
			mov_tween = move(Vector2i(sign(hor_diff), 0))
		else:
			mov_tween = move(Vector2i(0, sign(ver_diff)))
		
		if mov_tween:
			await mov_tween.finished


func get_absolute_pos() -> Vector2i:
	# Returns dice absolute position equivalent to current target position in coordinates
	return current_pos * MOV_DIST


func move(direction: Vector2i) -> Tween:
	var mov_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	current_pos += direction
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME/mov_num)
	
	return mov_tween


func _on_area_2d_area_entered(area):
	var player = area.get_parent()
	player.damage()
	queue_free()
