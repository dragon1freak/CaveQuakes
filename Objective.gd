extends StaticBody2D

signal harvested
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("objectives")

func harvest():
	print("we got harvested")
	emit_signal("harvested")
	WorldManager.harvest_objective()
	queue_free()
