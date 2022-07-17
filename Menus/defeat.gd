extends Control



func _input(event):
	if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left")\
		or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down")):
		
		get_tree().change_scene("res://Menus/MainMenu.tscn")
