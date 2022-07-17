extends Node2D


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3

@onready var game_level = get_parent().get_parent()
@onready var map_rows = game_level.MAP_SIZE.y
@onready var map_cols = game_level.MAP_SIZE.x
var astar = AStar2D.new()

var mov_num: int = 2
var current_pos: Vector2i = Vector2i.ONE
var life: int = 3
var is_frozen: bool = false


func spawn(pos: Vector2i) -> void:
	current_pos = pos
	position = current_pos * MOV_DIST


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


func getAvailablePoints(rows, cols, obstacles_positions):
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
				for j in [-1, 1]:
					if (x+j <= map_cols and x+j > 0 and Vector2i(x+j, y) not in obstacles_positions):
						neighbour_cell_id = getIdFromCoordinates(x+j, y)
						astar.connect_points(i, neighbour_cell_id)
					if (y+j <= map_rows and y+j > 0 and Vector2i(x, y+j) not in obstacles_positions):
						neighbour_cell_id = getIdFromCoordinates(x, y+j)
						astar.connect_points(i, neighbour_cell_id)
			i += 1


func getPathToPlayer(player_pos: Vector2i):
	# Returns a list of points (by id) that connect the enemy to the player
	var enemy_pos_id  = getIdFromCoordinates(current_pos.x, current_pos.y)
	var player_pos_id = getIdFromCoordinates(player_pos.x, player_pos.y)
	print("Enemy pos = {e} -- Player Pos = {p}".format({"e": enemy_pos_id, "p": player_pos_id}))
	var path = astar.get_point_path(enemy_pos_id, player_pos_id)
	return(path)


func getIdFromCoordinates(x: int, y: int):
	return((y-1) * map_cols + x)


func getCoordinatesFromId(id: int) -> Vector2i:
	var y: int = floor(id/map_cols) + 1
	var x: int = id % map_cols
	return(Vector2i(x, y))


func returnPathCoordinates(point_ids: Array):
	var path_coordinates = []
	for id in point_ids:
		path_coordinates.append(getCoordinatesFromId(id))
	return (path_coordinates)


func act(player_pos: Vector2i, obstacles: Array):
	if is_frozen:
		is_frozen = false
	else:
		unfreeze()
		getAvailablePoints(map_rows, map_cols, obstacles)
		var path_coordinates = getPathToPlayer(player_pos)
		print(current_pos)
		print(player_pos)
		print(path_coordinates)
		var moves_made = min(mov_num, len(path_coordinates)-1)
		
		var movements_to_be_made = []
		var x_mov = 0
		var y_mov  = 0
		
		for i in range(1, moves_made+1):
			x_mov = path_coordinates[i].x - path_coordinates[i-1].x
			y_mov = path_coordinates[i].y - path_coordinates[i-1].y
			movements_to_be_made.append(Vector2i(x_mov, y_mov))
		
		
		for movement in movements_to_be_made:
			move(movement)

