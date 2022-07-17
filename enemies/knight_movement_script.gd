extends "res://enemies/base_enemy.gd"


func move(direction: Vector2i) -> Tween:
	var mov_tween = create_tween().set_trans(Tween.TRANS_CIRC)
	
	mov_tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), MOV_TIME)
	if abs(direction.x) == 2:
		var destination = current_pos + Vector2i(direction.x, 0)
		mov_tween.chain().tween_property(self, "position", Vector2(destination * MOV_DIST), MOV_TIME/2)
	else:
		var destination = current_pos + Vector2i(0, direction.y)
		mov_tween.chain().tween_property(self, "position", Vector2(destination * MOV_DIST), MOV_TIME/2)
	current_pos += direction
	mov_tween.chain().tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME/2)
	
	mov_tween.chain().tween_property($Sprite2D, "scale", Vector2(1, 1), MOV_TIME)

	return mov_tween


func getAvailablePoints(rows, cols, obstacles_positions):
	# the horse moves in an L shape, and so we will be connecting the points by this pattern
	var i = 1
	var neighbour_cell_id: int
	var x_increment: int
	var y_increment: int
	mov_num = 1
	
	var possible_movements = [
		Vector2i(-2, -1),
		Vector2i(-1, -2),
		Vector2i(1, -2),
		Vector2i(2, -1),
		Vector2i(2, 1),
		Vector2i(1, 2),
		Vector2i(-1, 2),
		Vector2i(-2, 1)
	]
	
	for y in range(1, rows+1):
		for x in range(1, cols+1):
			if Vector2i(x, y) not in obstacles_positions:
				astar.add_point(i, Vector2i(x, y))
			i += 1
	
	i = 1
	for y in range(1, rows+1):
		for x in range(1, cols+1):
			if Vector2i(x, y) not in obstacles_positions:
#				for y_increment in [-1, 1]:
#					for x_increment in [-1, 1]:
				for possible_movement in possible_movements:
					x_increment = possible_movement.x
					y_increment = possible_movement.y
					if (x+x_increment<=map_cols and x+x_increment>0 and y+y_increment<=map_rows and y+y_increment>0 and Vector2i(x+x_increment, y+y_increment) not in obstacles_positions):
						neighbour_cell_id = getIdFromCoordinates(x+x_increment, y+y_increment)
						astar.connect_points(i, neighbour_cell_id)
			i += 1


func getRandomNeighbourCell(position: Vector2i, obstacles_positions):
	var possible_moves = [
		Vector2i(-1, 0),
		Vector2i(1, 0),
		Vector2i(0, -1),
		Vector2i(0, 1)
	]
	var new_position: Vector2i
	for move in possible_moves:
		new_position = position + move
		if ((new_position.x > 0) and (new_position.x <=map_cols) and (new_position.y > 0) and (new_position.y <= map_rows) and (new_position not in obstacles_positions)):
			return new_position
	return position


func getPathToPlayer(player_pos: Vector2i, obstacles_positions=[]):
	# Returns a list of points (by id) that connect the enemy to the player
	var enemy_pos_id  = getIdFromCoordinates(current_pos.x, current_pos.y)
	var player_pos_id = getIdFromCoordinates(player_pos.x,  player_pos.y)
	var path = astar.get_point_path(enemy_pos_id, player_pos_id)
	return(path)
	
func act(player_pos: Vector2i, obstacles: Array):
	if is_frozen:
		is_frozen = false
	else:
		unfreeze()
		getAvailablePoints(map_rows, map_cols, obstacles)
		var path_coordinates = getPathToPlayer(player_pos)
		var moves_made = min(mov_num, len(path_coordinates)-1)
		
		var movements_to_be_made = []
		var x_mov = 0
		var y_mov = 0
		
		for i in range(1, moves_made+1):
			x_mov = path_coordinates[i].x - path_coordinates[i-1].x
			y_mov = path_coordinates[i].y - path_coordinates[i-1].y
			movements_to_be_made.append(Vector2i(x_mov, y_mov))
		
		for movement in movements_to_be_made:
			var twn = move(movement)
