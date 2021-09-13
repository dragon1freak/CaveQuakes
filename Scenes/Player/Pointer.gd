extends Node2D

var target : StaticBody2D
var target_position : Vector2 = Vector2.ZERO
var tile_size : float
var detect_radius : float = 24
var plant_range : int

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func _process(_delta):
	if target_position:
		look_at(target_position)
		if global_position.distance_to(target_position) / tile_size <= detect_radius:
			modulate.a = max(global_position.distance_to(target_position) / tile_size / detect_radius - 0.2, 0)

func activate(_target : StaticBody2D, _plant_range : int = 80, _tile_size : float = 16.0):
	var _res = _target.connect("harvested", self, "on_target_harvested")
	set_process(true)
	self.target = target
	self.target_position = _target.global_position
	self.tile_size = _tile_size
	self.plant_range = _plant_range
	visible = true

func on_target_harvested():
	visible = false
	set_process(false)
