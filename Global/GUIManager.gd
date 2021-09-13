extends Node

onready var viewport : Viewport = get_tree().root

export var default_viewport_size : Vector2 = Vector2(384, 216)
export var zoom_level : int = 3
var resolutions : Array
var last_resolution_index : int = 0

var master_volume : float = 0.5
var music_volume : float = 0.5
var sound_volume : float = 0.5
var is_fullscreen : bool = false
var high_score : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	resolutions = [Vector2(1280, 720), Vector2(1024, 768), Vector2(1280, 1024), Vector2(1360, 768), Vector2(1366, 768), Vector2(1920, 1080)]
	resolution_change(0)
	load_save()

signal fullscreen
func set_player_health(health : int):
	$GUI/HealthBar.value = max(0, health)

func save():
	var save_data : Dictionary = { "master": master_volume, "music": music_volume, "sounds": sound_volume, "fullscreen": is_fullscreen, "score": high_score }
	var save_file : File = File.new()
	var _res = save_file.open("user://savefile.save", File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.close()

func load_save():
	var save_file : File = File.new()
	if save_file.file_exists("user://savefile.save"):
		var _res = save_file.open("user://savefile.save", File.READ)
		var save_data = parse_json(save_file.get_line())
		master_volume = save_data["master"]
		sound_volume = save_data["sounds"]
		music_volume = save_data["music"]
		is_fullscreen = save_data["fullscreen"]
		high_score = save_data["score"]
		save_file.close()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear2db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear2db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sounds"), linear2db(sound_volume))
	if is_fullscreen:
		toggle_fullscreen()

func _unhandled_input(event):
	if event.is_action_pressed("cycle_res") and !OS.window_fullscreen:
		var index : int = resolutions.find(OS.window_size)
		resolution_change(index + 1 if index != resolutions.size() - 1 else 0)
#	elif event.is_action_pressed("fullscreen"):
#		toggle_fullscreen()

func resolution_change(resolution_index: int):
	var new_resolution : Vector2 = resolutions[resolution_index]
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, new_resolution, zoom_level)
	# viewport.size = new_resolution
	OS.window_size = new_resolution
	OS.center_window()
	last_resolution_index = resolution_index

func toggle_fullscreen():
	if OS.window_fullscreen:
		OS.window_fullscreen = false
		resolution_change(last_resolution_index)
	else:
		OS.window_fullscreen = true
		get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, OS.get_screen_size(), 5)
	GuiManager.is_fullscreen = OS.window_fullscreen
	emit_signal("fullscreen")

func toggle_pause_menu(died : bool = false):
	var new_score = WorldManager.difficulty if died else WorldManager.difficulty + 1
	if new_score > high_score:
		high_score = new_score
	$GUI/PauseMenu/VBoxContainer/MenuText.bbcode_text = "[center]You've beaten " + str(WorldManager.difficulty + 1) + " levels![center]" if !died else "[center]You survived " + str(WorldManager.difficulty) + " levels...[center]"
	$GUI/PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/Next.visible = !died
	$GUI/PauseMenu/VBoxContainer/HBoxContainer/VBoxContainer/Retry.visible = died
	$GUI/PauseMenu.visible = !$GUI/PauseMenu.visible

func toggle_gui():
	$GUI.visible = !$GUI.visible

func toggle_dettimer(show : bool = false):
	$DetTimer.visible = show

func set_dettimer_text(text : String = ""):
	$DetTimer/VBoxContainer/Timer.text = text

func _on_Quit_pressed():
	save()
	$Select.play()
	get_tree().quit()

func _on_Next_pressed():
	$Select.play()
	WorldManager.next_level()

func _on_Menu_pressed():
	save()
	WorldManager.back_to_menu()
	$Select.play()

func _on_Retry_pressed():
	$Select.play()
	WorldManager.difficulty = -1
	WorldManager.next_level()
