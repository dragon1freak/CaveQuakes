extends StaticBody2D

func _ready():
	$AnimationPlayer.play("ShadowFall")

func trigger_rock():
	$AnimationPlayer.play("RockFall")

func rock_land():
	var squishables = $Rock/Area2D.get_overlapping_bodies()
	for squish in squishables:
		if squish.has_method("take_damage"):
			squish.take_damage(1000)
	$CollisionShape2D.disabled = false
	var tile_map = get_parent().get_node("Navigation2D/TileMap")
	var tile_coords = tile_map.world_to_map(self.global_position) 
	tile_map.set_cell(tile_coords.x, tile_coords.y, tile_map.get_tileset().get_tiles_ids()[2], false, false, false, tile_map.get_cell_autotile_coord(tile_coords.x, tile_coords.y))
