extends Node2D

const RANGE: int = 2
const DAMAGE: int = 3


func burn(player_pos: Vector2i):
	var enemies = get_parent().get_enemies()
	
	for en in enemies:
		if abs(Vector2(player_pos).distance_to(en.current_pos)) <= RANGE:
			en.damage(DAMAGE)
