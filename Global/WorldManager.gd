extends Node

onready var current_world : Node2D = get_tree().get_current_scene()

var portals : Array
var target_world : String
var player : Area2D
var next_spawn_point : String

func level_ready(level : Node2D):
	current_world = level
	if target_world:
		spawn_player()

func enter_portal(world : String, target_spawn_id : String):
	$AnimationPlayer.play("Fade")
	

func change_scene():
	$AnimationPlayer.stop(false)
	if target_world != current_world.name:
		var _result : int = get_tree().change_scene("res://Levels/" + target_world + ".tscn")
	else:
		spawn_player()

func spawn_player(spawn_point : Vector2 = Vector2.ZERO):
	$AnimationPlayer.play("Fade")
	if spawn_point and player != null:
		player.position = spawn_point
	else:
		var spawn : Area2D
		for portal in portals:
			if portal.spawn_id == next_spawn_point:
				spawn = portal
		if spawn:
			player.position = spawn.position
			player.move_target = spawn.get_spawn_point()
			target_world = ""

func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.stop()

