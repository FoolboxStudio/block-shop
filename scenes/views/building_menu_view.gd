extends View

@onready var packed_custom_button = preload("res://addons/foolish_godot/reusable_ui/custom_buttons/custom_button.tscn")

@export var building_datas: Array[BuildingData]
@export var destroy_data: BuildingData
@export var lock_texture: Texture2D

@export var reset_texture: Texture2D

@onready var v_box_container:= $PositionControl/PanelContainer/MarginContainer/VBoxContainer as Container
@onready var button_holder:= $PositionControl/PanelContainer/MarginContainer/VBoxContainer/ButtonHolder as Container

@onready var destroy_button_holder:= $PositionControl/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer as HBoxContainer


var destroy_button: CustomButton
var reset_button: CustomButton

var buttons: Array


func _ready() -> void:
	#create_buttons_from_data()
	SignalManager.switch_game_tool_menu_to.connect(switch_button_index)


func create_buttons_from_data(level_data: LevelData):
	buttons.clear()
	if destroy_button:
		destroy_button.queue_free()
	if reset_button:
		reset_button.queue_free()
	for button in button_holder.get_children():
		button.queue_free()
	
	for building_data in building_datas:
		var new_button = packed_custom_button.instantiate() as CustomButton
		if level_data.available_building.has(building_data.building_type) || level_data.available_building.is_empty():
			new_button.set_texture(building_data.texture_2d)
		
			new_button.toggle_mode = true
		
			new_button.button_down.connect(func(): get_tree().get_first_node_in_group("game_view").current_building_data = building_data)
			new_button.button_down.connect(func(): switch_button_visual(new_button))
		
			new_button.button_up.connect(func(): get_tree().get_first_node_in_group("game_view").reset_current_building_data())
			new_button.button_up.connect(get_tree().get_first_node_in_group("game_view").enable_all_buttons)
		else:
			new_button.set_texture(lock_texture)
			new_button.disable()
		
		buttons.append(new_button)
		
		button_holder.add_child(new_button)
	
	
	reset_button = packed_custom_button.instantiate() as CustomButton
	reset_button.set_texture(reset_texture)
	
	reset_button.pressed.connect(Commands.reset_level)
	
	buttons.append(reset_button)
	
	destroy_button_holder.add_child(reset_button)
	
	
	destroy_button = packed_custom_button.instantiate() as CustomButton
	destroy_button.set_texture(destroy_data.texture_2d)
	
	destroy_button.toggle_mode = true
	
	destroy_button.pressed.connect(toggle_destroy_button)
	
	buttons.append(destroy_button)
	
	destroy_button_holder.add_child(destroy_button)


func toggle_destroy_button():
	if destroy_button.button_pressed:
		get_tree().get_first_node_in_group("game_view").set_erase_mouse()
		get_tree().get_first_node_in_group("game_view").current_building_data = destroy_data
	else:
		get_tree().get_first_node_in_group("game_view").set_normal_mouse()
		get_tree().get_first_node_in_group("game_view").reset_current_building_data()


func switch_button_index(index: int):
	if index < buttons.size():
		buttons[index].pressed.emit()


func switch_button_visual(button: CustomButton):
	get_tree().get_first_node_in_group("game_view").enable_all_buttons()
	button.set_color(Color.BLACK)
	button.button_pressed = true


func enable_all_buttons():
	for button in buttons:
		button.reset_color()
		button.button_pressed = false
