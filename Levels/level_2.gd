extends "res://Levels/LevelTemplate.gd"

var enemy_list = {
	"base_enemy": 3,
	"bishop": 2
}

# Called when the node enters the scene tree for the first time.
func update_values():
	level = 2
	MAP_SIZE = Vector2i(29, 22)
	wall_positions = []
	enemies = createEnemyList(player_initial_position, enemy_list)
	var final_return = {
		"level_number": level,
		"MAP_SIZE": MAP_SIZE,
		"wall_positions": wall_positions,
		"enemies": enemies
	}
	return final_return
	
	
