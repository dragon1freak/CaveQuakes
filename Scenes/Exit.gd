extends Area2D

var open : bool = false

func open_the_exit():
	$Gate.frame = 0
	$Gate.get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", true)
	open = true
	$ExitArea.set_deferred("disabled", false)

func close_the_exit():
	$Gate.frame = 1
	$Gate.get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", false)
	open = false
	$ExitArea.set_deferred("disabled", true)

func _on_Exit_body_entered(body):
	if body.is_in_group("player"):
		close_the_exit()
		body.can_damage = false
		WorldManager.reach_exit()

func _on_DetectStart_body_exited(body):
	if body.is_in_group("player"):
		close_the_exit()
		body.can_damage = true
		WorldManager.started = true
