extends Control


func _on_button_pressed() -> void: #on button pressed, change scene to the game.
	get_tree().change_scene_to_file("res://game.tscn")
