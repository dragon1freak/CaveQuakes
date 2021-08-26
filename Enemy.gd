extends KinematicBody2D

export var speed : float = 50
export var health : int = 3

onready var player : KinematicBody2D = get_parent().get_node("Player")
var velocity : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity = position.direction_to(player.position) * speed
	velocity = move_and_slide(velocity)
	pass

func hit():
	health -= 1
	if health <= 0:
		queue_free()
	print("It did it")
