extends "res://enemies/base_enemy.gd"


func getAvailablePoints(rows, cols, obstacles_positions):
	# the bishop moves diagonally, and so we will only connect positions in a diagonal sense
	var i = 1
	var neighbour_cell_id: int
	
	for y in range(1, rows+1):
		for x in range(1, cols+1):
			if Vector2i(x, y) not in obstacles_positions:
				astar.add_point(i, Vector2i(x, y))
			i += 1
			
	i = 1
	for y in range(1, rows+1):
		for x in range(1, cols+1):
			if Vector2i(x, y) not in obstacles_positions:
				for y_increment in [-1, 1]:
					for x_increment in [-1, 1]:
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
	var isSameDiagonalTileSet: bool = ((player_pos.x + player_pos.y)%2) == ((current_pos.x + current_pos.y)%2)
	var target_player_pos: Vector2i
	if isSameDiagonalTileSet:
		target_player_pos = player_pos
	else:
		target_player_pos = getRandomNeighbourCell(player_pos, obstacles_positions)
	
	var enemy_pos_id  = getIdFromCoordinates(current_pos.x, current_pos.y)
	var player_pos_id = getIdFromCoordinates(target_player_pos.x,  target_player_pos.y)
	print("Enemy pos = {e} -- Player Pos = {p}".format({"e": enemy_pos_id, "p": player_pos_id}))
	var path = astar.get_point_path(enemy_pos_id, player_pos_id)
	return(path)
