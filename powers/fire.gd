extends Node2D

const DAMAGE = 2


func _on_area_2d_area_entered(area):
	area.get_parent().damage(DAMAGE)
