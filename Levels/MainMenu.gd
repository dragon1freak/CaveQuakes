extends Node2D

func _on_Quit_pressed():
	$Select.play()
	get_tree().quit()

func _on_Start_pressed():
	$Select.play()
	WorldManager.start_game()

func _on_Options_pressed():
	$Select.play()
	print("Go to main menu")
