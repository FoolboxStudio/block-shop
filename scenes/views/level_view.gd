extends View
class_name LevelView


@onready var custom_tile_control = preload("res://scenes/custom_tile_control.tscn")

@onready var grid_container:= $PositionControl/VBoxContainer/PanelContainer/MarginContainer/GridContainer as GridContainer

@onready var hint_box:= $PositionControl/VBoxContainer/PanelContainer3 as PanelContainer
@onready var hint_text:= $PositionControl/VBoxContainer/PanelContainer3/MarginContainer/RichTextLabel as RichTextLabel

var board_size: Vector2
var current_level_data: LevelData

var building_dictionary: Dictionary

var buildings: Array[Building]
var custom_tile_controls: Array[CustomTileControl]

@onready var level_name:= $PositionControl/VBoxContainer/PanelContainer/Control/Label as Label



func load_next_level(level_data: LevelData) -> void:
	current_level_data = level_data
	
	load_level(current_level_data)


func generate_board(grid_size: Vector2) -> void:
	_clear_board()
	
	board_size = grid_size
	grid_container.columns = grid_size.x
	var index = 0
	for j in grid_size.y:
		for i in grid_size.x:
			var grid_position = Vector2(i, j)
			if buildings.size() <= index:
				var new_custom_tile_control = custom_tile_control.instantiate() as CustomTileControl
				var new_building = new_custom_tile_control.get_building() as Building
				custom_tile_controls.append(new_custom_tile_control)
				buildings.append(new_building)
				grid_container.add_child(new_custom_tile_control)
			buildings[index].grid_position = grid_position
			building_dictionary[grid_position] = buildings[index]
			custom_tile_controls[index].visible = true
			index += 1


func _clear_board() -> void:
	building_dictionary.clear()
	for custom_tile_control in custom_tile_controls:
		custom_tile_control.custom_tile.building.current_building_data.can_be_overwritten = true
		custom_tile_control.custom_tile.building.reset()
		custom_tile_control.visible = false


#TODO: Used for testing, remove after cleaning up
func _process(delta: float) -> void:
	super._process(delta)

	if Input.is_action_just_pressed("save_level"):
		if get_tree().get_first_node_in_group("game_view").level_building_mode:
			_save_level()


func _save_level() -> void:
	var new_level_data = LevelData.new()
	new_level_data.board_size = board_size
	for building in building_dictionary.values():
		var new_custom_tile_data = CustomTileData.new()
		new_custom_tile_data.grid_position = building_dictionary.find_key(building)
		new_custom_tile_data.building_data = building.current_building_data.duplicate()
		
		if new_custom_tile_data.building_data.building_type == Enums.BuildingType.SPAWNER || new_custom_tile_data.building_data.building_type == Enums.BuildingType.DESPAWNER:
			new_custom_tile_data.building_data.can_be_overwritten = false
			new_custom_tile_data.building_data.texture_2d = ImageTexture.create_from_image(building.cube_image)
		
		for coming_from in building.coming_from_array:
			new_custom_tile_data.coming_from.append(building_dictionary.find_key(coming_from))
		
		for going_toward in building.going_toward_array:
			new_custom_tile_data.going_toward.append(building_dictionary.find_key(going_toward))
		
		new_level_data.custom_tile_data_array.append(new_custom_tile_data)
	
	new_level_data.resource_path = "res://level_data_" + str(Time.get_unix_time_from_system()) + ".tres"
	ResourceSaver.save(new_level_data)


func load_level(level_data: LevelData) -> void:
	generate_board(level_data.board_size)
	call_deferred("build_level", level_data)


func build_level(level_data: LevelData) -> void:
	if level_data.hint != "":
		hint_box.visible = true
		hint_text.text = level_data.hint
	else:
		hint_box.visible = false
	
	level_name.text = level_data.level_name
	
	for custom_tile_data in level_data.custom_tile_data_array:
		var current_building = building_dictionary[custom_tile_data.grid_position]
		
		for coming_from in custom_tile_data.coming_from:
			current_building.coming_from_array.append(building_dictionary[coming_from])
		
		for going_toward in custom_tile_data.going_toward:
			current_building.going_toward_array.append(building_dictionary[going_toward])
		
		current_building._construct_machine(custom_tile_data.building_data.duplicate())
