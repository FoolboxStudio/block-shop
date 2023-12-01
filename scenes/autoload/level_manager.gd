extends Node

@export var tutorial_index_start: int
@export var level_index_start: int
@export var level_list: Array[LevelData]

@export var max_level_reached: int

@export var current_level: int = 0


func _ready() -> void:
	max_level_reached = level_index_start


func get_first_tutorial_level() -> LevelData:
	get_tree().get_first_node_in_group("game_view").stop_level()
	current_level = tutorial_index_start
	var next_level = level_list[current_level]
	current_level += 1
	return next_level


func get_first_level() -> LevelData:
	get_tree().get_first_node_in_group("game_view").stop_level()
	current_level = max_level_reached
	var next_level = level_list[current_level]
	current_level += 1
	return next_level


func get_next_level() -> LevelData:
	if current_level >= level_list.size():
		return null
	
	get_tree().get_first_node_in_group("game_view").stop_level()
	var next_level = level_list[current_level]
	if current_level > level_index_start:
		max_level_reached = current_level
	current_level += 1
	return next_level
