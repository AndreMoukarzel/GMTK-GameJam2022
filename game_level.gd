extends Node

const MAP_SIZE = Vector2i(31, 18)

@export var Player: PackedScene
@export var initial_pos: Vector2i

# Called when the node enters the scene tree for the first time.
func _ready():
	var dice = Player.instantiate()
	var offset = Vector2i.ONE * dice.MOV_DIST/2
	dice.offset = MAP_SIZE
	dice.target_pos = initial_pos
	dice.position = dice.get_absolute_pos()
	add_child(dice)
