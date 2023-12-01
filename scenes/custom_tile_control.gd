extends Control
class_name CustomTileControl


@export var custom_tile: Area2D


func get_building() -> Building:
	return custom_tile.get_building()
