extends KinematicBody2D

export var MAX_SPEED : float = 500
export var ACCELERATION : float = 2000
export var accuracy : float = 0.1
var can_fire : bool = true
export var fire_rate : float = 0.1
var motion : Vector2 = Vector2.ZERO

var bullet = preload("res://Bullet.tscn")
var rng = RandomNumberGenerator.new()
#onready var camera : Camera2D = $Camera2D
#onready var tilemap : TileMap = get_parent().get_node("TileMap")
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	var camera : Camera2D = $Camera2D
	if camera:
		var tilemap = get_parent().get_node("TileMap")
		var tilemap_rect = tilemap.get_used_rect()
		camera.limit_left = tilemap_rect.position.x * tilemap.cell_size.x
		camera.limit_top = tilemap_rect.position.y * tilemap.cell_size.y
		camera.limit_right = camera.limit_left + tilemap_rect.size.x * tilemap.cell_size.x
		camera.limit_bottom = camera.limit_top + tilemap_rect.size.y * tilemap.cell_size.y

var fire_rate_counter : float = 0
func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		fire()
	if !can_fire:
		fire_rate_counter += delta
		if fire_rate_counter >= fire_rate:
			can_fire = true
			fire_rate_counter = 0
	var input_axis = get_input_axis()
	if input_axis == Vector2.ZERO:
		apply_friction(ACCELERATION * delta)
	else:
		apply_movement(input_axis * ACCELERATION * delta)
	motion = move_and_slide(motion)
	$Gun.look_at(get_global_mouse_position())

func get_input_axis() -> Vector2:
	var input : Vector2 = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"), 
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	return input.normalized()

func apply_friction(friction : float) -> void:
	if motion.length() > friction:
		motion -= motion.normalized() * friction
	else:
		motion = Vector2.ZERO

func apply_movement(movement : Vector2) -> void:
	motion += movement
	motion = motion.clamped(MAX_SPEED)

func fire():
	can_fire = false
	var bullet_instance = bullet.instance()
	bullet_instance.position = $Gun.global_position
	bullet_instance.direction = $Gun.global_position.direction_to(get_global_mouse_position()) + Vector2(rng.randf_range(-accuracy, accuracy), rng.randf_range(-accuracy, accuracy))
	get_tree().get_root().add_child(bullet_instance)

func take_damage(damage : int = 1):
	print("OW")
