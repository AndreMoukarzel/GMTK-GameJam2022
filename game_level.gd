extends Node

const MAP_SIZE = Vector2i(31, 18)

@export var PlayerScn: PackedScene
@export var initial_pos: Vector2i

var Player


func _ready():
	Player = PlayerScn.instantiate()
	var offset = Vector2i.ONE * Player.MOV_DIST/2
	Player.offset = MAP_SIZE
	Player.target_pos = initial_pos
	Player.position = Player.get_absolute_pos()
	add_child(Player)
	
	Player.connect("moved", self.next_turn)
	
	spawn_enemies()


func spawn_enemies():
	var enemy = load("res://enemies/base_enemy.tscn")
	
	for i in range(3):
		var enemy_inst = enemy.instantiate()
		var pos = Vector2i(randi_range(1, MAP_SIZE.x), randi_range(1, MAP_SIZE.y))
		
		while pos == Player.target_pos:
			pos = Vector2i(randi_range(1, MAP_SIZE.x + 1), randi_range(1, MAP_SIZE.y + 1))
		enemy_inst.spawn(pos)
		$Enemies.add_child(enemy_inst)


func next_turn() -> void:
	for child in $Enemies.get_children():
		child.act(Player.target_pos)
	
	if $Enemies.get_child_count() == 0:
		spawn_enemies()
