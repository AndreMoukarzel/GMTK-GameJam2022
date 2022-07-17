extends Node

var level_name: String
var level: int
var MAP_SIZE: Vector2i
var player_initial_position: Vector2i = Vector2i(10, 10)
var wall_positions: Array
var enemies: Array
var path_to_enemies: String = "res://enemies/"
var path_to_levels: String  = "res://Levels/"  
const range_to_spawn: int = 3

func generateRandomPlace(blocked_places):
	var map_cols = MAP_SIZE.x
	var map_rows = MAP_SIZE.y
	var rand_x: int
	var rand_y: int
	var isValidPlace: bool = false
	var selected_position: Vector2i
	
	while (!isValidPlace):
		rand_x = randi_range(0, map_cols)
		rand_y = randi_range(0, map_rows)
		selected_position = Vector2i(rand_x, rand_y)
		if selected_position not in blocked_places:
			return(selected_position)

func createEnemyList(player_pos, n_per_enemy):
	# n_per_enemy = number of enemies per type as a dictionary
	# type: number
	var enemy_list = []
	var enemy_info = []
	var blocked_places = []
	var impossible_to_spawn_region = []
	var spawn_pos: Vector2i
	for i in range(-range_to_spawn, range_to_spawn + 1):
		for j in range(-range_to_spawn, range_to_spawn + 1):
			impossible_to_spawn_region.append(player_pos + Vector2i(i, j))
	
	blocked_places = impossible_to_spawn_region
	
	for enemy in n_per_enemy:
		for i in range(n_per_enemy[enemy]):
			spawn_pos = generateRandomPlace(blocked_places)
			enemy_info = [enemy, spawn_pos]
			blocked_places.append(spawn_pos)
			enemy_list.append(enemy_info)
	return enemy_list
