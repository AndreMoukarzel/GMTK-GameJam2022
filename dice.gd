extends Node2D

signal moved
signal dashed


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3
const PROJ_TIME: float = 1.5 # Time to show the moves' projections
const PROJ_FADE_IN_TIME: float = 0.8

@export var FireScn: PackedScene
@export var IceScn: PackedScene
@export var RockScn: PackedScene
@export var PlantScn: PackedScene
@export var BoltScn: PackedScene
#@export var can_move_to_broken: bool = true

#var sides_broken = [false, false, false, false, false, false]
var life: int = 6
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
var projections_tween: Tween


func _ready():
	$MovTimer.wait_time = MOV_TIME
	$ProjTimer.wait_time = PROJ_TIME
	_update_projected_moves()


func _input(event) -> void:
	if $MovTimer.is_stopped():
		if event.is_action_pressed("ui_up"):
			if target_pos.y - 1 < 1:
				print("Invalid pos")
			else:
				move(Vector2i(0, -1))
		elif event.is_action_pressed("ui_down"):
			if offset and target_pos.y + 1 > offset.y:
				print("Invalid pos")
			else:
				move(Vector2i(0, 1))
		elif event.is_action_pressed("ui_right"):
			if offset and target_pos.x + 1 > offset.x:
				print("Invalid pos")
			else:
				move(Vector2i(1, 0))
		elif event.is_action_pressed("ui_left"):
			if target_pos.x - 1 < 1:
				print("Invalid pos")
			else:
				move(Vector2i(-1, 0))
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


func move(direction: Vector2i) -> void:
	var mov_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	
	target_pos += direction
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME)
	$MovTimer.start()
	
	if projections_tween:
		projections_tween.kill()
	$ProjectedMoves.modulate = Color(1, 1, 1, 0)
	$ProjTimer.start()
	
	sides = turn_dice(sides, direction)
	$Label.text = str(sides['top'])
	
	await mov_tween.finished
	if sides['top'] == 6:
		_fire()
	elif sides['top'] == 5:
		_ice()
	elif sides['top'] == 2:
		_rock(direction)
	elif sides['top'] == 1:
		_bolt()
	elif sides['top'] == 4:
		_air(direction)
		await dashed
	emit_signal("moved")


func damage(value: int=1):
	#sides_broken[sides['top']]
	life -= value
	print("Life = ", life)


func _update_projected_moves() -> void:
	$ProjectedMoves/Left/Label.text = str(sides['east'])
	$ProjectedMoves/Right/Label.text = str(sides['west'])
	$ProjectedMoves/Up/Label.text = str(sides['south'])
	$ProjectedMoves/Down/Label.text = str(sides['north'])
	$ProjectedMoves/Left.show()
	$ProjectedMoves/Right.show()
	$ProjectedMoves/Up.show()
	$ProjectedMoves/Down.show()
	
	if target_pos.x - 1 == 0:
		$ProjectedMoves/Left.hide()
	elif offset and target_pos.x + 1 > offset.x:
		$ProjectedMoves/Right.hide()
	
	if target_pos.y - 1 == 0:
		$ProjectedMoves/Up.hide()
	elif offset and target_pos.y + 1 > offset.y:
		$ProjectedMoves/Down.hide()


func _fire():
	var Fire = FireScn.instantiate()
	Fire.global_position = global_position
	get_parent().add_child(Fire)


func _ice():
	var enemy = get_parent().get_closest_enemy(target_pos)
	var Ice = IceScn.instantiate()
	
	enemy.freeze()
	
	Ice.global_position = get_absolute_pos()
	get_parent().add_child(Ice)
	Ice.fly_to(enemy, enemy.get_absolute_pos())


func _rock(direction: Vector2i) -> void:
	var Rock = RockScn.instantiate()
	
	Rock.global_position = (target_pos - direction) * MOV_DIST
	get_parent().add_child(Rock)


func _bolt():
	var enemy = get_parent().get_closest_enemy(target_pos)
	var Bolt = BoltScn.instantiate()
	
	Bolt.global_position = get_absolute_pos()
	get_parent().add_child(Bolt)
	Bolt.fly_to(enemy, enemy.get_absolute_pos())


func _air(direction: Vector2i) -> void:
	var mov_tween: Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	
	target_pos += 2 * direction
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME)
	await mov_tween.finished
	emit_signal("dashed")


func _on_proj_timer_timeout():
	projections_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	projections_tween.tween_property($ProjectedMoves, "modulate",\
		Color(1, 1, 1, 0.5), PROJ_FADE_IN_TIME)
