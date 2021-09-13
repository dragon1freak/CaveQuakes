extends Node2D

func _ready():
	$MenuLayer/Options/VBoxContainer/MasterContainer/MasterSlider.value = GuiManager.master_volume
	$MenuLayer/Options/VBoxContainer/MusicContainer/MusicSlider.value = GuiManager.music_volume
	$MenuLayer/Options/VBoxContainer/SoundContainer/SoundSlider.value = GuiManager.sound_volume
	$MenuLayer/Options/VBoxContainer/FullscreenToggleContainer/FullScreenToggle.pressed = GuiManager.is_fullscreen
	$MenuLayer/Main/HighScore.text = "Best: " + str(GuiManager.high_score)
	var _res = GuiManager.connect("fullscreen", self, "on_fullscreen_toggled")
	WorldManager.get_node("AnimationPlayer").play("FadeIn")

func _on_Quit_pressed():
	$Select.play()
	get_tree().quit()

func _on_Start_pressed():
	$Select.play()
	WorldManager.start_game()

func _on_Options_pressed():
	$Select.play()
	$MenuLayer/Main.visible = false
	$MenuLayer/Options.visible = true
	$MenuLayer/Options/VBoxContainer/FullscreenToggleContainer/FullScreenToggle.pressed = GuiManager.is_fullscreen

func _on_Back_pressed():
	$Select.play()
	$MenuLayer/Main.visible = true
	$MenuLayer/Options.visible = false
	GuiManager.save()

func _on_MasterSlider_value_changed(value):
	GuiManager.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(value))

func _on_MusicSlider_value_changed(value):
	GuiManager.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(value))
	
func _on_SoundSlider_value_changed(value):
	GuiManager.sound_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(value))

func _on_FullScreenToggle_pressed():
	GuiManager.toggle_fullscreen()

func on_fullscreen_toggled():
	$MenuLayer/Options/VBoxContainer/FullscreenToggleContainer/FullScreenToggle.pressed = OS.window_fullscreen

func _on_ControlsBack_pressed():
	$Select.play()
	$MenuLayer/Main.visible = true
	$MenuLayer/HowTo.visible = false

func _on_HowToPlay_pressed():
	$Select.play()
	$MenuLayer/Main.visible = false
	$MenuLayer/HowTo.visible = true
