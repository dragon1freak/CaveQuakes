extends KinematicBody2D

export var speed : float = 150
export var health : int = 2
export var projectile_speed : float = 200
export var spread_angle : int = 15
export var attack_speed : float = 1
export var attack_range : float = 16 * 8
export var follow_range : float = attack_range * 1.5
var is_following : bool = true

var bullet = preload("res://Scenes/Enemies/EnemyBullet.tscn")
onready var player : KinematicBody2D = get_tree().get_current_scene().get_node("Player")
onready var tile_map : TileMap = get_tree().get_current_scene().get_node("Navigation2D/TileMap")
enum {WALL, FLOOR}
var velocity : Vector2 = Vector2.ZERO

var attack_tick = attack_speed
func _physics_process(delta):
	tick(delta)
	if player != null:
		if is_following:
			velocity = position.direction_to(player.position) * speed
			velocity = move_and_slide(velocity)
		elif position.distance_to(player.global_position) > follow_range:
			is_following = true
		if attack_tick >= attack_speed and position.distance_to(player.global_position) <= (attack_range if is_following else follow_range):
			if !isInWall():
				attack()

func isInWall():
	var wall = $WallCheck.get_overlapping_areas()
	var tile_id = tile_map.get_cellv(tile_map.world_to_map(position - position.direction_to(player.position).normalized() * 16))
	return tile_id == WALL or wall.size() > 0

func tick(delta):
	attack_tick += delta

func attack():
	$Shoot.play()
	is_following = false
	attack_tick = 0
	var dir_to_player = self.global_position.direction_to(player.global_position)
	fire(dir_to_player)
	fire(dir_to_player.rotated(deg2rad(spread_angle)))
	fire(dir_to_player.rotated(deg2rad(-spread_angle)))

func fire(fire_direction : Vector2 = Vector2.ZERO, fire_position : Vector2 = position):
	var bullet_instance = bullet.instance()
	bullet_instance.position = fire_position
	bullet_instance.direction = fire_direction
	bullet_instance.speed = projectile_speed
	get_tree().get_current_scene().add_child(bullet_instance)

func take_damage(damage : int = 1):
	health -= damage
	if health <= 0:
		queue_free()
