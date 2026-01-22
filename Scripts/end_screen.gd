extends Control


func _ready() -> void:
	$Victory.play() #play victory sound
	$FinalTime.text = "Final Time: " + Nodesender.final_time #edits final time
	$TotalCoins.text = Nodesender.total_coins #edits total coins
	$TotalDeaths.text = Nodesender.total_deaths #total deaths

func _on_button_pressed() -> void:
	get_tree().quit() #exits game if pressed


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn") #goes back to start of game when play again clicked
