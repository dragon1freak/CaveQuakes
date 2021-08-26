extends KinematicBody2D

export var speed : float = 50
export var health : int = 3
export var attack_speed : float = 0.5
export var attack_range : float = 16

onready var player : KinematicBody2D = get_parent().get_node("Player")
var velocity : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var attack_tick = 0.25
func _physics_process(delta):
	tick(delta)
	velocity = position.direction_to(player.position) * speed
	velocity = move_and_slide(velocity)
	if attack_tick >= attack_speed and position.distance_to(player.global_position) <= attack_range:
		attack()

func tick(delta):
	attack_tick += delta

func attack():
	attack_tick = 0
	if position.distance_to(player.global_position) <= attack_range:
		player.take_damage()

func take_damage(damage : int = 1):
	health -= damage
	if health <= 0:
		queue_free()
