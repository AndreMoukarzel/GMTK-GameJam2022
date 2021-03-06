extends Node2D

signal moved
signal dashed
signal iced


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3
const PROJ_TIME: float = 1.5 # Time to show the moves' projections
const PROJ_FADE_IN_TIME: float = 0.8

@export var FireScn: PackedScene
@export var IceScn: PackedScene
@export var RockScn: PackedScene
@export var PlantScn: PackedScene
@export var BoltScn: PackedScene
@export var AirScn: PackedScene


var target_pos: Vector2i = Vector2i.ONE
var offset
var sides: Dictionary = {
	'top': 1,
	'south': 2,
	'east': 3,
	'west': 4,
	'north': 5,
	'bottom': 6
}
var sides_to_powers = ["bolt", "rock", "plant", "wind", "ice", "fire"]
var sides_broken = []
var projections_tween: Tween
var can_move: bool = true


func _ready():
	$MovTimer.wait_time = MOV_TIME
	$ProjTimer.wait_time = PROJ_TIME
	_update_projected_moves()


func _input(event) -> void:
	if can_move:
		var obstacles_positions = get_parent().obstacles
		var enemy_positions = get_parent().get_enemies_coordinates()
		if event.is_action_pressed("ui_up"):
			if target_pos.y - 1 < 1\
				or target_pos - Vector2i(0, 1) in obstacles_positions:
				print("Invalid pos")
			else:
				move(Vector2i(0, -1), obstacles_positions, enemy_positions)
		elif event.is_action_pressed("ui_down"):
			if offset and target_pos.y + 1 > offset.y\
				or target_pos + Vector2i(0, 1) in obstacles_positions:
				print("Invalid pos")
			else:
				move(Vector2i(0, 1), obstacles_positions, enemy_positions)
		elif event.is_action_pressed("ui_right"):
			if offset and target_pos.x + 1 > offset.x\
				or target_pos + Vector2i(1, 0) in obstacles_positions:
				print("Invalid pos")
			else:
				move(Vector2i(1, 0), obstacles_positions, enemy_positions)
		elif event.is_action_pressed("ui_left"):
			if target_pos.x - 1 < 1\
				or target_pos - Vector2i(1, 0) in obstacles_positions:
				print("Invalid pos")
			else:
				move(Vector2i(-1, 0), obstacles_positions, enemy_positions)
		_update_projected_moves()


func turn_dice(posicoes: Dictionary, direction: Vector2i) -> Dictionary:
	# Defines new side of dice
	var faces = posicoes.keys()
	var numeros = posicoes.values()
	var inverse = {}
	for i in range(len(faces)):
		inverse[numeros[i]] = faces[i]
	var aux_copy = posicoes.duplicate()
	var changed_sides = []
	if direction.x == 1: # Right
		changed_sides = ['top', 'east', 'bottom', 'west']
	elif direction.x == -1: # Left
		changed_sides = ['west', 'bottom', 'east', 'top']
	
	if direction.y == -1: # Up
		changed_sides = ['south', 'top', 'north', 'bottom']
	elif direction.y == 1: # Down
		changed_sides = ['bottom', 'north', 'top', 'south']
	for i in range(len(changed_sides)):
		if i < (len(changed_sides) - 1):
			aux_copy[changed_sides[i+1]] = posicoes[changed_sides[i]]
		else:
			aux_copy[changed_sides[0]] = posicoes[changed_sides[-1]]
	return aux_copy


func get_absolute_pos() -> Vector2i:
	# Returns dice absolute position equivalent to current target position in coordinates
	return target_pos * MOV_DIST


func int2power(value: int) -> String:
	return sides_to_powers[value - 1]


func move(direction: Vector2i, obstacles: Array, enemy_positions: Array) -> void:
	can_move = false
	var mov_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	
	target_pos += direction
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME)
	$MovTimer.start()
	
	if projections_tween:
		projections_tween.kill()
	$ProjectedMoves.modulate = Color(1, 1, 1, 0)
	$ProjTimer.start()
	
	sides = turn_dice(sides, direction)
	_animate_dice_roll(direction)
	
	await mov_tween.finished
	if sides['top'] == 6 and int2power(sides['top']) not in sides_broken:
		_fire()
	elif sides['top'] == 5 and int2power(sides['top']) not in sides_broken:
		_ice()
		await iced
	elif sides['top'] == 2 and int2power(sides['top']) not in sides_broken:
		_rock(direction)
	elif sides['top'] == 1 and int2power(sides['top']) not in sides_broken:
		_bolt()
	elif sides['top'] == 4 and int2power(sides['top']) not in sides_broken:
		_air(direction)
		await dashed
	elif sides['top'] == 3 and int2power(sides['top']) not in sides_broken:
		_plant(direction, obstacles + enemy_positions)
	emit_signal("moved")


func damage(value: int=1):
	var current_power = int2power(sides['top'])
	if current_power not in sides_broken:
		sides_broken.append(current_power)
		$AnimationPlayer.play("break")
	else: # Break another random side
		var side_to_break = randi_range(1, 6)
		while int2power(side_to_break) in sides_broken:
			side_to_break = randi_range(1, 6)
		sides_broken.append(int2power(side_to_break))
		$DamageSfx.play()
	_update_projected_modulates()
	
	if len(sides_broken) >= 6:
		get_parent().fade_out()


func _update_projected_modulates():
	if int2power(sides['east']) in sides_broken:
		$ProjectedMoves/Left.modulate = Color(0.1, 0.1, 0.1)
	else:
		$ProjectedMoves/Left.modulate = Color(1, 1, 1)
	if int2power(sides['west']) in sides_broken:
		$ProjectedMoves/Right.modulate = Color(0.1, 0.1, 0.1)
	else:
		$ProjectedMoves/Right.modulate = Color(1, 1, 1)
	if int2power(sides['south']) in sides_broken:
		$ProjectedMoves/Up.modulate = Color(0.1, 0.1, 0.1)
	else:
		$ProjectedMoves/Up.modulate = Color(1, 1, 1)
	if int2power(sides['north']) in sides_broken:
		$ProjectedMoves/Down.modulate = Color(0.1, 0.1, 0.1)
	else:
		$ProjectedMoves/Down.modulate = Color(1, 1, 1)


func _update_projected_moves() -> void:
	$ProjectedMoves/Left.texture = load("res://dice/" + int2power(sides['east']) + ".png")
	$ProjectedMoves/Right.texture = load("res://dice/" + int2power(sides['west']) + ".png")
	$ProjectedMoves/Up.texture= load("res://dice/" + int2power(sides['south']) + ".png")
	$ProjectedMoves/Down.texture = load("res://dice/" + int2power(sides['north']) + ".png")
	$ProjectedMoves/Left.show()
	$ProjectedMoves/Right.show()
	$ProjectedMoves/Up.show()
	$ProjectedMoves/Down.show()
	
	_update_projected_modulates()
	
	if target_pos.x - 1 == 0:
		$ProjectedMoves/Left.hide()
	elif offset and target_pos.x + 1 > offset.x:
		$ProjectedMoves/Right.hide()
	
	if target_pos.y - 1 == 0:
		$ProjectedMoves/Up.hide()
	elif offset and target_pos.y + 1 > offset.y:
		$ProjectedMoves/Down.hide()


func _animate_dice_roll(direction: Vector2i) -> void:
	var top_twn = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	var sec_twn = create_tween().set_trans(Tween.TRANS_QUAD).set_parallel()
	
	$MoveSfx.play()
	$Top.modulate = Color(1, 1, 1)
	$Secondary.texture = load("res://dice/" + int2power(sides['top']) + ".png")
	if int2power(sides['top']) in sides_broken:
		$Secondary.modulate = Color(0.1, 0.1, 0.1)
	else:
		$Secondary.modulate = Color(1, 1, 1)
	
	if direction.x != 0:
		$Secondary.position = -direction * 16
		$Secondary.scale = Vector2(0.0, 0.125)
		
		top_twn.tween_property($Top, "position", Vector2(direction) * 16, MOV_TIME)
		top_twn.parallel().tween_property($Top, "scale", Vector2(0.0, 0.125), MOV_TIME)
		
		sec_twn.tween_property($Secondary, "position", Vector2(0, 0), MOV_TIME)
		sec_twn.parallel().tween_property($Secondary, "scale", Vector2(0.125, 0.125), MOV_TIME)
	elif direction.y != 0:
		$Secondary.position = -direction * 16
		$Secondary.scale = Vector2(0.125, 0.0)
		
		top_twn.tween_property($Top, "position", Vector2(direction) * 16, MOV_TIME)
		top_twn.parallel().tween_property($Top, "scale", Vector2(0.125, 0.0), MOV_TIME)
		
		sec_twn.tween_property($Secondary, "position", Vector2(0, 0), MOV_TIME)
		sec_twn.parallel().tween_property($Secondary, "scale", Vector2(0.125, 0.125), MOV_TIME)
	
	await top_twn.finished
	$Top.scale = Vector2(0.125, 0.125)
	$Top.position = Vector2(0, 0)
	$Top.texture = load("res://dice/" + int2power(sides['top']) + ".png")
	if int2power(sides['top']) in sides_broken:
		$Top.modulate = Color(0.1, 0.1, 0.1)
	else:
		$Top.modulate = Color(1, 1, 1)
	


func _fire():
	var Fire = FireScn.instantiate()
	Fire.global_position = global_position
	get_parent().add_child(Fire)
	Fire.burn(target_pos)


func _ice():
	var enemy = get_parent().get_closest_enemy(target_pos)
	var Ice = IceScn.instantiate()
	
	if is_instance_valid(enemy):
		enemy.freeze()
	
	Ice.global_position = get_absolute_pos()
	get_parent().add_child(Ice)
	Ice.fly_to(enemy)
	await Ice.done
	emit_signal("iced")


func _rock(direction: Vector2i) -> void:
	var Rock = RockScn.instantiate()
	
	Rock.global_position = (target_pos - direction) * MOV_DIST
	get_parent().add_child(Rock)


func _bolt():
	var enemy = get_parent().get_most_distant_enemy(target_pos)
	var Bolt = BoltScn.instantiate()
	
	Bolt.global_position = get_absolute_pos()
	get_parent().add_child(Bolt)
	Bolt.fly_to(enemy)


func _air(direction: Vector2i) -> void:
	var Air1 = AirScn.instantiate()
	var Air2 = AirScn.instantiate()
	var mov_tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	var air_angle = Vector2(1, 0).angle_to(direction)
	var old_pos = target_pos
	
	target_pos += 2 * direction
	target_pos.x = clampi(target_pos.x, 1, offset.x)
	target_pos.y = clampi(target_pos.y, 1, offset.y)
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME)
	
	Air1.position = (target_pos - direction) * MOV_DIST
	Air1.rotation = air_angle
	get_parent().add_child(Air1)
	if Vector2(old_pos).distance_to(target_pos) == 2:
		Air2.position = (target_pos - 2 * direction) * MOV_DIST
		Air2.rotation = air_angle
		get_parent().add_child(Air2)
	await mov_tween.finished
	emit_signal("dashed")


func _plant(direction: Vector2i, obstacles_positions: Array) -> void:
	var Plant1 = PlantScn.instantiate()
	var Plant2 = PlantScn.instantiate()
	var Plant3 = PlantScn.instantiate()
	var plant1_pos = (target_pos + 2 * -direction) + Vector2i(-direction.y, -direction.x)
	var plant2_pos = (target_pos + 2 * -direction)
	var plant3_pos = (target_pos + 2 * -direction) + Vector2i(direction.y, direction.x)
	
	get_parent().get_node("Plants").add_child(Plant1)
	get_parent().get_node("Plants").add_child(Plant2)
	get_parent().get_node("Plants").add_child(Plant3)
	Plant1.grow(plant1_pos, MOV_DIST, obstacles_positions)
	Plant2.grow(plant2_pos, MOV_DIST, obstacles_positions)
	Plant3.grow(plant3_pos, MOV_DIST,obstacles_positions)


func _on_proj_timer_timeout():
	projections_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	projections_tween.tween_property($ProjectedMoves, "modulate",\
		Color(1, 1, 1, 0.5), PROJ_FADE_IN_TIME)
