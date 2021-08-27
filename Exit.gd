extends Area2D

var open : bool = false



func _on_Exit_body_entered(body):
	if body.is_in_group("player"):
		$Gate.get_node("StaticBody2D/CollisionShape2D").disabled = false
		open = false
		WorldManager.reach_exit()
