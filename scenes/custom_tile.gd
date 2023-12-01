extends Area2D
class_name CustomTile


@export var can_be_drawn_on: bool = true
@export var can_be_drawn_texture: Texture2D
@export var cannot_be_drawn_texture: Texture2D

@export var building: Building

@onready var collision_shape_2d:= $CollisionShape2D as CollisionShape2D

var current_cube_image: Image

@onready var background:= $Background as Sprite2D


func _ready() -> void:
	if can_be_drawn_on:
		background.texture = can_be_drawn_texture
	else:
		background.texture = cannot_be_drawn_texture


func get_building() -> Building:
	return building


func reset_tile():
	building.reset()


func _mouse_enter() -> void:
	if get_tree().get_first_node_in_group("game_view").is_level_started: return
	
	if !can_be_drawn_on: return
	
	get_tree().get_first_node_in_group("game_view").hovered_tile = self
	update_visual_to_enter()


func update_visual_to_enter():
	building.update_visual_to_enter()


func _mouse_exit() -> void:
	if get_tree().get_first_node_in_group("game_view").is_level_started: return
	
	if !can_be_drawn_on: return
	
	if get_tree().get_first_node_in_group("game_view").hovered_tile == self:
		get_tree().get_first_node_in_group("game_view").hovered_tile = null
	update_visual_to_exit()


func update_visual_to_exit():
	building.update_visual_to_exit()


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if get_tree().get_first_node_in_group("game_view").is_level_started: return
	
	if !can_be_drawn_on: return
	
	if Input.is_action_pressed("left_click"):
		match get_tree().get_first_node_in_group("game_view").current_building_data.building_type:
			Enums.BuildingType.CONVEYOR:
				building.on_click()
				get_tree().get_first_node_in_group("game_view").handle_last_tile(self)
			Enums.BuildingType.NONE:
				reset_tile()
				building.on_click()
