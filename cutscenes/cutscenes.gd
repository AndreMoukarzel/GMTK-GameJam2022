extends Control


var scene = 1
var changing_scene = false


func _input(event):
	if (event.is_action_pressed("ui_up") or event.is_action_pressed("ui_left")\
		or event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"))\
		and not changing_scene:
		
		$AnimationPlayer.play("fade_in")
		await $AnimationPlayer.animation_finished
		scene += 1
		if scene <= 3:
			get_node("TextureRect" + str(scene)).show()
			$AnimationPlayer.play("fade_out")
			await $AnimationPlayer.animation_finished
		elif scene > 3:
			get_tree().change_scene("res://game_level.tscn")
