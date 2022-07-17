extends "res://Levels/LevelTemplate.gd"


func update_values():
	level = 1
	MAP_SIZE = Vector2i(27, 17)
	wall_positions = [
		Vector2i(12, 8),
		Vector2i(13, 8),
		Vector2i(14, 8),
		Vector2i(12, 9),
		Vector2i(13, 9),
		Vector2i(14, 9),
		Vector2i(12, 10),
		Vector2i(13, 10),
		Vector2i(14, 10)
	]
	enemies = [
		["base_enemy", Vector2i(25, 3)]
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
	
