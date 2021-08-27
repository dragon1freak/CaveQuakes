extends Node

onready var current_world : Node2D = get_tree().get_current_scene()

var tile_map : TileMap
var target_world : String
onready var player : KinematicBody2D = get_tree().get_current_scene().get_node("Player")
var boulder : PackedScene = preload("res://Boulder.tscn")
var next_spawn_point : String
var objective_count : int

var spawn_delay : float = 0.25

var quake_timing : float = 0.1
var quaking : bool = false

var walker : PackedScene = preload("res://Enemy.tscn")
var flyer : PackedScene = preload("res://Shooter.tscn")
export var difficulty : int = 1
var swarm : bool = false
var MAX_WALKERS_COUNT : int = 10
var MAX_FLYERS_COUNT : int = 4

var rng = RandomNumberGenerator.new()
enum {WALL, FLOOR}

func level_ready(map : TileMap):
	tile_map = map
	objective_count = get_tree().get_nodes_in_group("objectives").size()
	spawn_player()

func enter_portal(world : String, target_spawn_id : String):
	$AnimationPlayer.play("Fade")

func reach_exit():
	print("Exited")

func spawn_player(spawn_point : Vector2 = Vector2.ZERO):
	$AnimationPlayer.play("FadeIn")
	player.position = Vector2(tile_map.cell_size.x * 2, tile_map.get_used_rect().size.y * tile_map.cell_size.y / 2)

func harvest_objective():
	objective_count -= 1
	if objective_count <= 0:
		trigger_quake()

func trigger_quake():
	print("Quaking")
	rng.randomize()
	quaking = true
	swarm = true

var quake_tick : float = quake_timing
var spawn_tick : float = spawn_delay
var wait_to_spawn : float = 0
func _physics_process(delta):
	tick(delta)
	if quaking:
		if quake_tick >= quake_timing - difficulty / 100:
			quake()
			quake_tick = 0.0
	if spawn_tick >= spawn_delay and wait_to_spawn >= 3.0:
		spawn_enemy()

func tick(delta : float):
	quake_tick += delta
	spawn_tick += delta
	wait_to_spawn += delta

func spawn_enemy():
	var walker_count = get_tree().get_nodes_in_group("walker").size()
	var flyer_count = get_tree().get_nodes_in_group("flyer").size()
	var swarm_multiplier = 2 if swarm else 1
	if walker_count < MAX_WALKERS_COUNT * 1 + (float(difficulty) * float(swarm_multiplier)) / 10:
		var new_walker = walker.instance()
		var open_cells = tile_map.get_used_cells_by_id(FLOOR)
		var spawn_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
		new_walker.global_position = tile_map.map_to_world(spawn_position)
		new_walker.player = player
		new_walker.tile_map = tile_map
		if quaking:
			new_walker.speed = player.MAX_SPEED - 10
		get_tree().get_current_scene().get_node("Enemies").add_child(new_walker)
	elif flyer_count < MAX_FLYERS_COUNT * 1 + (float(difficulty) * float(swarm_multiplier)) / 10:
		var new_flyer = flyer.instance()
		var open_cells = tile_map.get_used_cells_by_id(FLOOR)
		var spawn_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
		new_flyer.global_position = tile_map.map_to_world(spawn_position)
		new_flyer.player = player
		new_flyer.tile_map = tile_map
		if quaking:
			new_flyer.speed = player.MAX_SPEED + 10
		get_tree().get_current_scene().get_node("Enemies").add_child(new_flyer)


func quake():
	var width = tile_map.get_used_rect().size.x * tile_map.cell_size.x
	var height = tile_map.get_used_rect().size.y * tile_map.cell_size.y
	var open_cells = tile_map.get_used_cells_by_id(FLOOR)
	var placement_position = open_cells[rng.randi_range(0, open_cells.size() - 1)]
	var boulder_instance = boulder.instance()
	boulder_instance.position = tile_map.map_to_world(placement_position) + tile_map.cell_size * 0.5
	get_tree().get_current_scene().add_child(boulder_instance)

func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.stop()
