extends "res://Levels/LevelTemplate.gd"


func update_values():
	level = 1
	MAP_SIZE = Vector2i(42, 31)
	wall_positions = []
	enemies = [
		["base_enemy", Vector2i(1, 5)]
		, ["base_enemy", Vector2i(16, 13)]
		, ["base_enemy", Vector2i(1, 17)]
	]
	var final_return = {
		"level_number": level,
		"MAP_SIZE": MAP_SIZE,
		"wall_positions": wall_positions,
		"enemies": enemies
	}
	return (final_return)
	
