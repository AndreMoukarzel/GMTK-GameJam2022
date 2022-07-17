extends Node

var level_number: int
var MAP_SIZE: Vector2i
var wall_positions: Array
var enemies: Array
var path_to_enemies: String = "res://enemies/"
var path_to_levels:  String  = "res://Levels/"
var level_values


func instantiateNewLevel(level_name):
	var level_path = path_to_levels + level_name + ".gd"
	var level = load(level_path).new()
	level_values = level.update_values()
	level_number = level_values["level_number"]
	MAP_SIZE = level_values["MAP_SIZE"]
	wall_positions = level_values["wall_positions"]
	enemies = level_values["wall_positions"]
	get_parent().MAP_SIZE = MAP_SIZE
	var e
	var e_pos
	var e_inst
	for enemy in level.enemies:
		e = load("{path}{enemy_type}.tscn".format({"path": path_to_enemies, "enemy_type": enemy[0]}))
		e_inst = e.instantiate()
		e_pos = enemy[1]
		e_inst.spawn(e_pos)
		get_parent().get_node("Enemies").add_child(e_inst)
