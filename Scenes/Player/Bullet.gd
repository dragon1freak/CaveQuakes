extends KinematicBody2D

var direction : Vector2 = Vector2.ZERO
export var speed : int = 500

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		hit(collision)

func hit(collision):
	if collision.collider.has_method("take_damage"):
		collision.collider.take_damage(1)
	queue_free()
