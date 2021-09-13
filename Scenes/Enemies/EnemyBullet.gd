extends KinematicBody2D

var direction : Vector2 = Vector2.ZERO
export var speed : int = 200
var splat : PackedScene = preload("res://Scenes/Player/PlayerSplatter.tscn")

func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		hit(collision)

func hit(collision):
	if collision.collider.has_method("take_damage"):
		var splatter = splat.instance()
		splatter.global_position = collision.position
		splatter.direction = -direction
		get_tree().get_root().add_child(splatter)
		splatter.emitting = true
		collision.collider.take_damage(1)
	queue_free()
