extends Sprite

func _process(_delta):
	if global_rotation_degrees > 90 or global_rotation_degrees < -90:
		flip_v = true
		$Barrel.position = Vector2(6, 4)
	else:
		flip_v = false
		$Barrel.position = Vector2(6, -4)
