extends Node

const MAP_SIZE = Vector2i(27, 17)

@export var PlayerScn: PackedScene
@export var initial_pos: Vector2i

var Player
var obstacles = []


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


func get_enemies():
	var enemies = []
	for child in $Enemies.get_children():
		if "duration" in child: # Is a plant, not an enemy
			pass
		elif is_instance_valid(child):
			enemies.append(child)
	return enemies


func get_closest_enemy(pos: Vector2i) -> Node2D:
	var enemies = get_enemies()
	if len(enemies) == 0:
		return null
	var closest = enemies[0]
	for en in enemies:
		if Vector2(pos).distance_to(en.current_pos) < Vector2(pos).distance_to(closest.current_pos):
			closest = en
	return closest


func get_enemies_coordinates(exclude=Vector2i.ZERO):
	var enemies = get_enemies()
	var positions = []
	for en in enemies:
		if exclude == Vector2i.ZERO or en.current_pos != exclude:
			positions.append(en.current_pos)
	return positions


func get_most_distant_enemy(pos: Vector2i) -> Node2D:
	var enemies = get_enemies()
	if len(enemies) == 0:
		return null
	var distant = enemies[0]
	for en in enemies:
		if Vector2(pos).distance_to(en.current_pos) > Vector2(pos).distance_to(distant.current_pos):
			distant = en
	return distant


func next_turn() -> void:
	$EnemyActionDelay.start()
	await $EnemyActionDelay.timeout
	for child in get_enemies():
		if is_instance_valid(child):
			var obstacles_and_enemies = obstacles + get_enemies_coordinates(child.current_pos)
			child.act(Player.target_pos, obstacles_and_enemies)
			$EnemyActionDelay.start()
			await $EnemyActionDelay.timeout
	
	if $Enemies.get_child_count() == 0:
		spawn_enemies()
