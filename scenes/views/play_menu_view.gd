extends View

@onready var packed_custom_button = preload("res://addons/foolish_godot/reusable_ui/custom_buttons/custom_button.tscn")

@export var start_button_texture: Texture2D
@export var stop_button_texture: Texture2D
@export var speed_up_button_texture: Texture2D


@onready var button_holder:= $PositionControl/PanelContainer/MarginContainer/ButtonHolder as Container

var buttons: Array


func _ready() -> void:
	create_buttons_from_data()


func create_buttons_from_data():
	create_stop_button()
	create_start_button()


func create_start_button():
	var new_button = packed_custom_button.instantiate() as CustomButton
	new_button.set_texture(start_button_texture)
	new_button.pressed.connect(get_tree().get_first_node_in_group("game_view").start_level)
	
	button_holder.add_child(new_button)


func create_stop_button():
	var new_button = packed_custom_button.instantiate() as CustomButton
	new_button.set_texture(stop_button_texture)
	new_button.pressed.connect(get_tree().get_first_node_in_group("game_view").stop_level)
	
	button_holder.add_child(new_button)


func switch_button_visual(button: CustomButton):
	enable_all_buttons()
	button.button_pressed = true


func enable_all_buttons():
	for button in buttons:
		button.button_pressed = false
