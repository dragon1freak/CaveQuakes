extends KinematicBody2D

export var speed : float = 120
export var health : int = 2
export var attack_speed : float = 0.5
export var attack_range : float = 20

onready var tile_map : TileMap
enum {WALL, FLOOR}
onready var player : KinematicBody2D
var is_seen : bool = false
var is_tunneling : bool = true
var velocity : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var attack_tick = 0.25
var tunnel_tick = 0
var tunnel_delay = 1
func _physics_process(delta):
	tick(delta)
	if player != null:
		if global_position.distance_to(player.global_position) > attack_range:
			var dir : Vector2 = global_position.direction_to(player.global_position)
			velocity = position.direction_to(player.global_position - dir * 16) * speed
			velocity = move_and_slide(velocity)
		if attack_tick >= attack_speed and position.distance_to(player.global_position) <= attack_range:
			attack()
		if is_seen and !isInWall():
			self.set_collision_mask_bit(0, true)
		elif !is_seen and tunnel_tick >= tunnel_delay:
			self.set_collision_mask_bit(0, false)


func tick(delta):
	attack_tick += delta
	tunnel_tick += delta

func isInWall():
	var tile_id = tile_map.get_cellv(tile_map.world_to_map(position - position.direction_to(player.position).normalized() * tile_map.cell_size.x))
	return tile_id == WALL

func attack():
	attack_tick = 0
	if position.distance_to(player.global_position) <= attack_range:
		player.take_damage()

func take_damage(damage : int = 1):
	health -= damage
	if health <= 0:
		queue_free()


func _on_VisibilityEnabler2D_screen_entered():
	is_seen = true
	pass # Replace with function body.


func _on_VisibilityEnabler2D_screen_exited():
	is_seen = false
	pass # Replace with function body.
