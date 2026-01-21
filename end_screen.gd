extends Control


func _ready() -> void:
	$Victory.play()
	$FinalTime.text = "Final Time: " + Nodesender.final_time
	$TotalCoins.text = Nodesender.total_coins
	$TotalDeaths.text = Nodesender.total_deaths

func _on_button_pressed() -> void:
	get_tree().quit()
