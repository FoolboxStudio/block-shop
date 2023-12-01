extends View

@onready var packed_custom_button = preload("res://addons/foolish_godot/reusable_ui/custom_buttons/custom_button.tscn")

@export var building_datas: Array[BuildingData]

@onready var button_holder:= $PositionControl/PanelContainer/MarginContainer/ButtonHolder as Container

var buttons: Array


func _ready() -> void:
	create_buttons_from_data()


func create_buttons_from_data():
	for building_data in building_datas:
		var new_button = packed_custom_button.instantiate() as CustomButton
		new_button.set_texture(building_data.texture_2d)
		
		new_button.toggle_mode = true
		
		new_button.button_down.connect(func(): get_tree().get_first_node_in_group("game_view").current_building_data = building_data)
		new_button.button_down.connect(func(): switch_button_visual(new_button))
		
		new_button.button_up.connect(func(): get_tree().get_first_node_in_group("game_view").reset_current_building_data())
		new_button.button_up.connect(get_tree().get_first_node_in_group("game_view").enable_all_buttons)
		
		buttons.append(new_button)
		
		button_holder.add_child(new_button)


func switch_button_visual(button: CustomButton):
	get_tree().get_first_node_in_group("game_view").enable_all_buttons()
	button.button_pressed = true


func enable_all_buttons():
	for button in buttons:
		button.button_pressed = false
