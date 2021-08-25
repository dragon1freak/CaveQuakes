extends KinematicBody2D

var direction : Vector2 = Vector2.ZERO
export var speed : int = 500

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		hit(collision)

func hit(collision):
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass # Replace with function body.
