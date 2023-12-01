extends Node2D
class_name Cube


@export var speed: float = 45
var going_toward: CustomTile


func move_toward(move_position: Vector2, delta: float):
	global_position = global_position.move_toward(move_position, speed * delta)
