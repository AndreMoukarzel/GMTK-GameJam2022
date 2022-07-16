extends Node2D


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3

var mov_num: int = 2
var current_pos: Vector2i = Vector2i.ONE
var life: int = 3
var is_frozen: bool = false


func spawn(pos: Vector2i) -> void:
	current_pos = pos
	position = current_pos * MOV_DIST


func act(player_pos: Vector2i) -> void:
	if is_frozen:
		is_frozen = false
	else:
		unfreeze()
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


func damage(value: int) -> void:
	life -= value
	if life <= 0:
		queue_free()


func freeze() -> void:
	is_frozen = true


func unfreeze() -> void:
	modulate = Color(1, 1, 1)


func freeze_fx() -> void:
	modulate = Color(0, 0, 1)


func _on_area_2d_area_entered(area):
	var player = area.get_parent()
	player.damage()
	queue_free()
