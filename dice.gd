extends Node2D

signal moved


const MOV_DIST: int = 32
const MOV_TIME: float = 0.3

var target_pos: Vector2i = Vector2i.ONE
var offset


var positions: Dictionary = {
	'f1': 1,
	'f2': 2,
	'f3': 3,
	'f4': 4,
	'f5': 5,
	'f6': 6
}

func _ready():
	$MovTimer.wait_time = MOV_TIME


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


func turn_dice(posicoes: Dictionary, direction: Vector2i) -> Dictionary:
	# Defines new side of dice
	var faces = posicoes.keys()
	var numeros = posicoes.values()
	var inverse = {}
	for i in range(len(faces)):
		inverse[numeros[i]] = faces[i]
	var aux_copy = posicoes.duplicate()
	var changed_positions = []
	if direction.x == 1: # Right
		changed_positions = ['f1', 'f3', 'f6', 'f4']
	elif direction.x == -1: # Left
		changed_positions = ['f4', 'f6', 'f3', 'f1']
	elif direction.y == -1: # Up
		changed_positions = ['f2', 'f1', 'f5', 'f6']
	elif direction.y == 1: # Down
		changed_positions = ['f6', 'f5', 'f1', 'f2']
	for i in range(len(changed_positions)):
		if i < (len(changed_positions) - 1):
			aux_copy[changed_positions[i+1]] = posicoes[changed_positions[i]]
		else:
			aux_copy[changed_positions[0]] = posicoes[changed_positions[-1]]
	return aux_copy


func get_absolute_pos() -> Vector2i:
	# Returns dice absolute position equivalent to current target position in coordinates
	return target_pos * MOV_DIST


func move(direction: Vector2i) -> void:
	var mov_tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	target_pos += direction
	mov_tween.tween_property(self, "position", Vector2(get_absolute_pos()), MOV_TIME)
	$MovTimer.start()
	emit_signal("moved")
	positions = turn_dice(positions, direction)
	$Label.text = str(positions['f1'])
