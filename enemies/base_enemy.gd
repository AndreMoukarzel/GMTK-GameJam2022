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


@onready var game_level = get_parent().get_parent()
@onready var astar = AStar2D.new()

@onready var map_rows = game_level.MAP_SIZE.y
@onready var map_cols = game_level.MAP_SIZE.x


func getAvailablePoints(rows, cols, obstacles_positions):
	var i = 1
	
	var neighbour_cell_id = 0
	for r in range(1, rows+1):
		for c in range(1, cols+1):
			if Vector2i(r, c) not in obstacles_positions:
				astar.add_point(i, Vector2i(r, c))
			i += 1
	i = 1
	for r in range(1, rows+1):
		for c in range(1, cols+1):
			if Vector2i(r, c) not in obstacles_positions:
				for j in [-1, 1]:
					if (r + j < map_rows and r + j > 0 and Vector2i(r+j, c) not in obstacles_positions):
						neighbour_cell_id = getIdFromCoordinates(r + j, c)
						astar.connect_points(i, neighbour_cell_id)
					if (c + j < map_cols and c + j > 0 and Vector2i(r, c+j) not in obstacles_positions):
						neighbour_cell_id = getIdFromCoordinates(r, c + j)
						astar.connect_points(i, neighbour_cell_id)
			i += 1


func getPathToPlayer(player_pos: Vector2i):
	# Returns a list of points (by id) that connect the enemy to the player
	var enemy_pos_id  = getIdFromCoordinates(current_pos.y, current_pos.x)
	var player_pos_id = getIdFromCoordinates(player_pos.y, player_pos.x)
	print("Enemy pos = {e} -- Player Pos = {p}".format({"e": enemy_pos_id, "p": player_pos_id}))
	var path = astar.get_point_path(enemy_pos_id, player_pos_id)
	return(path)


func getIdFromCoordinates(row: int, col: int):
	return((row-1) * map_cols + col)


func getCoordinatesFromId(id: int) -> Vector2i:
	var row: int = floor(id/map_cols) + 1
	var col: int = id % map_cols
	return(Vector2i(row+1, col))


func returnPathCoordinates(point_ids: Array):
	var path_coordinates = []
	for id in point_ids:
		path_coordinates.append(getCoordinatesFromId(id))
	return (path_coordinates)


func act(player_pos: Vector2i):
	# Implementar: pegar os obstãculos existentes no mapa
	getAvailablePoints(map_rows, map_cols, [])
	var path_coordinates = getPathToPlayer(player_pos)
	var moves_made = min(mov_num, len(path_coordinates)-1)

	var movements_to_be_made = []
	var vert_mov = 0
	var hor_mov  = 0

	for i in range(1, moves_made+1):
		hor_mov = path_coordinates[i][1] - path_coordinates[i-1][1]
		vert_mov = path_coordinates[i][0] - path_coordinates[i-1][0]
		movements_to_be_made.append(Vector2i(hor_mov, vert_mov))
	
	for movement in movements_to_be_made:
		move(movement)
