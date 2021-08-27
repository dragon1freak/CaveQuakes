extends Node

onready var viewport : Viewport = get_tree().root

export var default_viewport_size : Vector2 = Vector2(384, 216)
export var zoom_level : int = 3
var resolutions : Array
var last_resolution_index : int

# Called when the node enters the scene tree for the first time.
func _ready():
	resolutions =  [default_viewport_size * 4,  Vector2(1280, 720), Vector2(1024, 768), Vector2(1280, 1024), Vector2(1360, 768), Vector2(1366, 768)]
	resolution_change(1)

func set_player_health(health : int):
	$HealthBar.value = max(0, health)

func _unhandled_input(event):
	if event.is_action_pressed("cycle_res") and !OS.window_fullscreen:
		var index : int = resolutions.find(OS.window_size)
		resolution_change(index + 1 if index != resolutions.size() - 1 else 0)
	elif event.is_action_pressed("fullscreen"):
		if OS.window_fullscreen:
			resolution_change(last_resolution_index)
		else:
			get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, OS.get_screen_size(), 5)
		OS.window_fullscreen = !OS.window_fullscreen
		print(OS.window_size)

func resolution_change(resolution_index: int):
	var new_resolution : Vector2 = resolutions[resolution_index]
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_EXPAND, new_resolution, zoom_level)
	# viewport.size = new_resolution
	OS.window_size = new_resolution
	OS.center_window()
	last_resolution_index = resolution_index
	print("Viewport: " + String(viewport.size))
	print(OS.window_size)
