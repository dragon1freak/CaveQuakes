extends KinematicBody2D

export var MAX_SPEED : float = 200
export var MAX_HEALTH : int = 100
export var MAX_ACCELERATION : float = 2000

var speed : float = MAX_SPEED
var acceleration : float = MAX_ACCELERATION
export var health : int = MAX_HEALTH

export var accuracy : float = 0.1
var can_fire : bool = true
export var fire_rate : float = 0.1
export var plant_range : int = 80
var can_plant : bool = false
var planted : bool = false
var plant_target = null
var motion : Vector2 = Vector2.ZERO
var dead : bool = false
var can_damage : bool = false

var bullet = preload("res://Scenes/Player/Bullet.tscn")
var harvester = preload("res://Scenes/Player/Harvester.tscn")
var rng = RandomNumberGenerator.new()

var objectives = []
onready var pointers = get_tree().get_nodes_in_group("pointers")

# Called when the node enters the scene tree for the first time.
func _ready():
	WorldManager.player_ready(self)
	rng.randomize()
	var camera : Camera2D = $Camera2D
	if camera:
		var tilemap = get_parent().get_node("TileMap")
		var tilemap_rect = tilemap.get_used_rect()
		camera.limit_left = tilemap_rect.position.x * tilemap.cell_size.x
		camera.limit_top = tilemap_rect.position.y * tilemap.cell_size.y
		camera.limit_right = camera.limit_left + tilemap_rect.size.x * tilemap.cell_size.x
		camera.limit_bottom = camera.limit_top + tilemap_rect.size.y * tilemap.cell_size.y
	pointers

var fire_rate_counter : float = 0
func _physics_process(delta):
	if Input.is_action_pressed("fire") and can_fire:
		fire()
	if !can_fire:
		fire_rate_counter += delta
		if fire_rate_counter >= fire_rate:
			can_fire = true
			fire_rate_counter = 0

	if Input.is_action_just_pressed("plant") and can_plant and !planted:
		plant()

	if $SlowRange.get_overlapping_bodies().size() > 0:
		speed = MAX_SPEED / 2
	else: 
		speed = MAX_SPEED
	var input_axis = get_input_axis()
	if input_axis == Vector2.ZERO:
		apply_friction(acceleration * delta)
	else:
		apply_movement(input_axis * acceleration * delta)
	motion = move_and_slide(motion)
	$Gun.look_at(get_global_mouse_position())
	if !objectives:
		set_obj_pointers()

func get_input_axis() -> Vector2:
	var input : Vector2 = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"), 
			Input.get_action_strength("down") - Input.get_action_strength("up")
		)
	return input.normalized()

func apply_friction(friction : float) -> void:
	if motion.length() > friction:
		motion -= motion.normalized() * friction
	else:
		motion = Vector2.ZERO

func apply_movement(movement : Vector2) -> void:
	motion += movement
	motion = motion.clamped(speed)

func fire():
	$Sounds/Shoot.play()
	can_fire = false
	var bullet_instance = bullet.instance()
	bullet_instance.position = $Gun.global_position
	bullet_instance.direction = $Gun.global_position.direction_to(get_global_mouse_position()).rotated(deg2rad(rng.randf_range(-accuracy, accuracy)))
	get_tree().get_root().add_child(bullet_instance)

func take_damage(damage : int = 1):
	if can_damage:
		if $Camera2D.trauma <= 0.1:
			$Camera2D.add_trauma(0.5)
		$Sounds/Hurt.play()
		health -= damage
		GuiManager.set_player_health(float(health) / float(MAX_HEALTH) * 100)
		if health <= 0 and !dead:
			dead = true
			get_tree().set_group("enemies", "player", null)
			get_tree().set_group("harvesters", "player", null)
			self.visible = false
			GuiManager.toggle_pause_menu(true)
			set_physics_process(false)

func set_obj_pointers():
	objectives = get_tree().get_nodes_in_group("objectives")
	WorldManager.objective_count = max(1, objectives.size())
	var index = 0
	for obj in objectives:
		if obj:
			pointers[index].activate(obj)
		index += 1

func plant():
	var harvester_instance = harvester.instance()
	harvester_instance.target = plant_target
	harvester_instance.player = self
	harvester_instance.position = position + Vector2.UP * 16
	harvester_instance.connect("removed", self, "_on_harvester_removed")
	get_tree().get_root().add_child(harvester_instance)
	planted = true
	$PlantNotifier.visible = false

func set_can_plant(plantable):
	can_plant = true
	if !plant_target or global_position.distance_to(plantable.global_position) < global_position.distance_to(plant_target.global_position):
		plant_target = plantable

func _on_PlantRange_body_entered(body):
	if body.is_in_group("objectives"):
		if !planted:
			$PlantNotifier.visible = true
		plant_target = body
		can_plant = true

func _on_PlantRange_body_exited(body):
	if body.is_in_group("objectives"):
		if $PlantRange.get_overlapping_bodies().size() <= 0:
			plant_target = null
			$PlantNotifier.visible = false
		else:
			plant_target = $PlantRange.get_overlapping_bodies()[0]

func _on_harvester_removed(harvester):
	harvester.disconnect("removed", self, "_on_harvester_removed")
	planted = false
	can_plant = false
	plant_target = null
