extends "res://Levels/LevelTemplate.gd"

var enemy_list = {
	"base_enemy": 2
}

#@onready var player_initial_pos = get_parent().initial_pos

func update_values():
	level = 1
	MAP_SIZE = Vector2i(29, 22)
	wall_positions = []
#	enemies = [
#		["base_enemy", Vector2i(1, 5)],
#		["base_enemy", Vector2i(16, 13)],
#		["base_enemy", Vector2i(14, 11)],
#		["base_enemy", Vector2i(16, 11)],
#		["base_enemy", Vector2i(15, 10)],
#		["base_enemy", Vector2i(15, 12)],
#		["base_enemy", Vector2i(16, 12)]
#	]
#	var player_initial_pos = Vector2i(10, 10)
	enemies = createEnemyList(player_initial_position, enemy_list)
#	enemies = createEnemyList(enemy_list)
	var final_return = {
		"level_number": level,
		"MAP_SIZE": MAP_SIZE,
		"wall_positions": wall_positions,
		"enemies": enemies
	}
	return (final_return)
	
