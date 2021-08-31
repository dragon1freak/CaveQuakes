extends KinematicBody2D

var target : StaticBody2D = null
var player : KinematicBody2D = null

export var speed : int = 200
export var mining_speed : int = 1
var moving : bool = true
var harvesting : bool = false
var detonating : bool = false
var max_detonate_time : int = 3
var detonate_time : int = max_detonate_time

signal removed
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var mining_tick = 0.0
var detonate_tick = 1.0
func _physics_process(delta):
	if moving:
		move_and_collide(global_position.direction_to(target.global_position + Vector2.UP * 16) * speed * delta)
		if global_position.distance_to(target.global_position + Vector2.UP * 16) < speed / 100:
			global_position = target.global_position + Vector2.UP * 16
			moving = false
			harvesting = true
			WorldManager.swarm = true
			$Mining.emitting = true
	if harvesting:
		mining_tick += delta
		if mining_tick >= mining_speed:
			$TextureProgress.value += 10
			mining_tick = 0.0
		if $TextureProgress.value >= 100:
			harvesting = false
			print("Done :)")
			target.harvest()
			$Mining.emitting = false
			WorldManager.swarm = false
			emit_signal("removed", self)
			queue_free()
		if player == null or global_position.distance_to(player.global_position) >= player.plant_range * 3:
			if !detonating:
				detonating = true
				GuiManager.toggle_dettimer(true)
				GuiManager.set_dettimer_text(str(3))
		else:
			detonate_time = max_detonate_time
			detonating = false
			GuiManager.toggle_dettimer()
			GuiManager.set_dettimer_text(str(detonate_time))
		if detonating:
			detonate_tick += delta
			if detonate_tick >= 1.0:
				if detonate_time > 0:
					GuiManager.set_dettimer_text(str(detonate_time))
					print("Detonating in" + str(detonate_time))
					detonate_tick = 0.0
					detonate_time -= 1
				else:
					detonate()

func detonate():
	GuiManager.toggle_dettimer()
	GuiManager.set_dettimer_text(str(3))
	$Mining.emitting = false
	$Boom.play()
	$Explode.emitting = true
	WorldManager.swarm = false
	emit_signal("removed", self)
	print("we blowd up cause u left")
	queue_free()
