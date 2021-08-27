extends Node2D

var target : StaticBody2D
var target_position : Vector2 = Vector2.ZERO
var tile_size : float
var detect_radius : float = 24
var plant_range : int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func _process(delta):
	if target_position:
		look_at(target_position)
		if global_position.distance_to(target_position) / tile_size <= detect_radius:
			modulate.a = max(global_position.distance_to(target_position) / tile_size / detect_radius - 0.2, 0)

func activate(target : StaticBody2D, plant_range : int = 80, tile_size : float = 16.0):
	target.connect("harvested", self, "on_target_harvested")
	set_process(true)
	self.target = target
	self.target_position = target.global_position
	self.tile_size = tile_size
	self.plant_range = plant_range
	visible = true

func on_target_harvested():
	visible = false
	set_process(false)
