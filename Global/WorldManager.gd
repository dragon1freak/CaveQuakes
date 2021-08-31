extends Node

onready var current_world : Node2D = get_tree().get_current_scene()

var tile_map : TileMap
var target_world : String
onready var player : KinematicBody2D
var boulder : PackedScene = preload("res://Scenes/Boulder.tscn")
var exit : Area2D
var next_spawn_point : String
var objective_count : int

var spawn_delay : float = 0.25

var quake_timing : float = 0.2
var quaking : bool = false

var walker : PackedScene = preload("res://Scenes/Enemies/Enemy.tscn")
var flyer : PackedScene = preload("res://Scenes/Enemies/Shooter.tscn")
export var difficulty : int = 0
var swarm : bool = false
var MAX_WALKERS_COUNT : int = 4
var MAX_FLYERS_COUNT : int = 1

var rng = RandomNumberGenerator.new()
enum {WALL, FLOOR}

func reset():
	difficulty = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func toggle_fade():
	$Fade.visible = !$Fade.visible

func start_game(start : bool = false):
	if !start:
		$AnimationPlayer.play("Start")
	else:
		GuiManager.toggle_gui()
		get_tree().change_scene("res://Levels/Caves.tscn")

func player_ready(player : KinematicBody2D):
	self.player = player
	get_tree().get_current_scene().get_node("TileMap/CaveGen").generate_level()

func level_ready(map : TileMap):
	print("Difficulty: " + str(difficulty))
	tile_map = map
	objective_count = get_tree().get_nodes_in_group("objectives").size()
	spawn_player()

func enter_portal(world : String, target_spawn_id : String):
	$AnimationPlayer.play("Fade")

func reach_exit():
	GuiManager.toggle_pause_menu()
	print("Exited")

func spawn_player(spawn_point : Vector2 = Vector2.ZERO):
	$AnimationPlayer.play("FadeIn")
	player.position = Vector2(tile_map.cell_size.x * 2, tile_map.get_used_rect().size.y * tile_map.cell_size.y / 2)

func harvest_objective():
	objective_count -= 1
	if objective_count <= 0:
		trigger_quake()

func trigger_quake():
	$Rumble.play()
	rng.randomize()
	quaking = true
	swarm = true
	var exit = get_tree().get_current_scene().get_node("Exit")
	exit.open_the_exit()

var quake_tick : float = quake_timing
var spawn_tick : float = spawn_delay
var wait_to_spawn : float = 0
var started : bool = false
func _physics_process(delta):
	tick(delta)
	if quaking:
		if quake_tick >= max(quake_timing - difficulty / 20, 0.01):
			quake()
			quake_tick = 0.0
	if spawn_tick >= spawn_delay and wait_to_spawn >= 2.0:
		spawn_enemy()

func tick(delta : float):
	quake_tick += delta
	spawn_tick += delta
	if started:
		wait_to_spawn += delta

func spawn_enemy():
	var walker_count = get_tree().get_nodes_in_group("walker").size()
	var flyer_count = get_tree().get_nodes_in_group("flyer").size()
	var swarm_multiplier = 2 if swarm else 1
	if walker_count < MAX_WALKERS_COUNT * 1 + (float(difficulty) * float(swarm_multiplier)):
		var new_walker = walker.instance()
		var open_cells = tile_map.get_used_cells_by_id(FLOOR)
		var spawn_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
		new_walker.global_position = tile_map.map_to_world(spawn_position)
		new_walker.player = player
		new_walker.tile_map = tile_map
		if quaking:
			new_walker.speed = player.MAX_SPEED - 50
		get_tree().get_current_scene().get_node("Enemies").add_child(new_walker)
	elif flyer_count < MAX_FLYERS_COUNT * 1 + (float(difficulty) * float(swarm_multiplier)):
		var new_flyer = flyer.instance()
		var open_cells = tile_map.get_used_cells_by_id(FLOOR)
		var spawn_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
		new_flyer.global_position = tile_map.map_to_world(spawn_position)
		new_flyer.player = player
		new_flyer.tile_map = tile_map
		if quaking:
			new_flyer.speed = player.MAX_SPEED - 50
		get_tree().get_current_scene().get_node("Enemies").add_child(new_flyer)

func next_level(move_on : bool = false):
	if !move_on:
		$Rumble.stop()
		GuiManager.toggle_pause_menu()
		$AnimationPlayer.play("FadeOut")
	else:
		difficulty += 1
		started = false
		quaking = false
		wait_to_spawn = 0.0
		player.health = player.MAX_HEALTH
		GuiManager.set_player_health(100)
		get_tree().call_group("enemies", "queue_free")
		get_tree().call_group("objectives", "queue_free")
		get_tree().reload_current_scene()

func quake():
	if player.get_node("Camera2D").trauma <= 0.5:
		player.get_node("Camera2D").add_trauma(0.5)
	var width = tile_map.get_used_rect().size.x * tile_map.cell_size.x
	var height = tile_map.get_used_rect().size.y * tile_map.cell_size.y
	var open_cells = tile_map.get_used_cells_by_id(FLOOR)
	var placement_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
	var boulder_instance = boulder.instance()
	boulder_instance.position = tile_map.map_to_world(placement_position) + tile_map.cell_size * 0.5
	get_tree().get_current_scene().add_child(boulder_instance)

func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.stop()
