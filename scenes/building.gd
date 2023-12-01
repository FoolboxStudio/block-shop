extends Sprite2D
class_name Building


@onready var default_building_data: BuildingData = preload("res://resources/building_data/destroyer.tres")
var current_building_data: BuildingData

var coming_from_array: Array[Building]
var going_toward_array: Array[Building]

@onready var conveyor:= $Conveyor as Conveyor
@onready var machine:= $Machine as Machine

var current_cube_array: Array[BigCube]

var cube_image: Image

var has_transformed: bool
var going_toward_index: int

var grid_position: Vector2

var game_view

@onready var wrong_input_player:= $WrongInputPlayer as AudioStreamPlayer2D
@onready var machine_build:= $MachineBuild as AudioStreamPlayer2D



func clear_current_cube():
	for current_cube in current_cube_array:
		current_cube.queue_free()
	current_cube_array.clear()
	has_transformed = false


func add_cube(cube: BigCube) -> bool:
	if has_transformed: return false
	
	if current_cube_array.size() >= current_building_data.coming_from_amount_allowed: return false
	
	for current_cube in current_cube_array:
		if current_cube.last_building == cube.last_building: return false
	
	current_cube_array.append(cube)
	cube.last_building.remove_cube(cube)
	return true


func get_inline_current_cube() -> BigCube:
	for current_cube in current_cube_array:
		if are_buildings_in_line(current_cube.last_building, going_toward_array[0]):
			return current_cube
	return null


func are_buildings_in_line(building1: Building, building2: Building):
	var check_x = building1.global_position.x == building2.global_position.x
	var check_y = building1.global_position.y == building2.global_position.y
	return check_x || check_y


func remove_cube(cube: BigCube):
	var index = current_cube_array.find(cube)
	if index >= 0:
		current_cube_array.remove_at(index)


func reset():
	if !current_building_data.can_be_overwritten: return
	
	current_building_data = default_building_data
	
	if !current_cube_array.is_empty():
		for current_cube in current_cube_array:
			current_cube.queue_free()
		current_cube_array.clear()
	
	for coming_from in coming_from_array:
		coming_from.remove_going_toward(self)
	
	for going_toward in going_toward_array:
		going_toward.remove_coming_from(self)
	
	coming_from_array.clear()
	going_toward_array.clear()
	
	has_transformed = false
	
	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)
	machine.machine_outline.visible = false
	machine.visible = true
	
	cube_image = null
	
	hide_conveyor()
	hide_machine()


func _ready() -> void:
	game_view = get_tree().get_first_node_in_group("game_view")
	current_building_data = default_building_data
	reset()


func _physics_process(delta: float) -> void:
	if !game_view.is_level_started: return
	
	if current_cube_array.is_empty():
		create_cube()
	
	var procede_with_transformation = true
	for current_cube in current_cube_array:
		current_cube.move_toward(global_position, delta)
		
	if are_all_cubes_in_position():
		transform_cube()
		if has_transformed:
			match current_building_data.building_type:
				Enums.BuildingType.SLICER:
					distribute_all_going_forward()
				_: give_to_random_next_going_forward()


func check_neighbours():
	while coming_from_array.size() > current_building_data.coming_from_amount_allowed:
		coming_from_array[0].remove_going_toward(self)
		coming_from_array.remove_at(0)
	
	while going_toward_array.size() > current_building_data.going_toward_amount_allowed:
		going_toward_array[0].remove_coming_from(self)
		going_toward_array.remove_at(0)
	
	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)


func allows_coming_from() -> bool:
	return current_building_data.coming_from_amount_allowed > 0


func add_coming_from(building: Building):
	if current_building_data.coming_from_amount_allowed == 0: return
	
	if coming_from_array.has(building): return
	
	remove_going_toward(building)
	
	if current_building_data.no_in_line_inputs:
		for coming_from in coming_from_array:
			if are_buildings_in_line(coming_from, building):
				coming_from.remove_going_toward(self)
				remove_coming_from(coming_from)
				break
	
	coming_from_array.append(building)
	
	if coming_from_array.size() > current_building_data.coming_from_amount_allowed:
		coming_from_array[0].remove_going_toward(self)
		coming_from_array.remove_at(0)
	
	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)


func remove_coming_from(building: Building):
	var index = coming_from_array.find(building)
	if index >= 0:
		coming_from_array.remove_at(index)
	
	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)


func allows_going_toward() -> bool:
	return current_building_data.going_toward_amount_allowed > 0


func add_going_toward(building: Building):
	if current_building_data.going_toward_amount_allowed == 0: return
	
	if going_toward_array.has(building): return
	
	remove_coming_from(building)
	
	going_toward_array.append(building)
	
	if going_toward_array.size() > current_building_data.going_toward_amount_allowed:
		going_toward_array[0].remove_coming_from(self)
		going_toward_array.remove_at(0)
	
	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)


func remove_going_toward(building: Building):
	var index = going_toward_array.find(building)
	if index >= 0:
		going_toward_array.remove_at(index)

	conveyor.update_conveyor_animation(going_toward_array, coming_from_array, grid_position)
	machine.update_doors_visual(going_toward_array, coming_from_array, grid_position)


func on_click():
	if is_not_empty_or_conveyor(current_building_data) && get_tree().get_first_node_in_group("game_view").current_building_data.building_type == Enums.BuildingType.CONVEYOR: return
	
	_construct_machine(get_tree().get_first_node_in_group("game_view").current_building_data)


func _construct_machine(building_data: BuildingData):
	if !current_building_data.can_be_overwritten: return
	
	current_building_data = building_data
	
	match current_building_data.building_type:
		Enums.BuildingType.SPAWNER:
			cube_image = building_data.texture_2d.get_image()
			machine.set_symbol_texture(building_data.texture_2d, building_data.keep_original_color)
			machine.set_machine_outline(ColorManager.machine_starting_color)
		Enums.BuildingType.DESPAWNER:
			game_view.increment_building_to_solve(self)
			cube_image = building_data.texture_2d.get_image()
			machine.set_symbol_texture(building_data.texture_2d, building_data.keep_original_color)
			machine.set_machine_outline(ColorManager.machine_ending_color)
		Enums.BuildingType.CONVEYOR:
			pass
		Enums.BuildingType.NONE:
			pass
		_ :
			if !game_view.is_main_screen:
				machine_build.pitch_scale = randf_range(0.95, 1.05)
				machine_build.play()
	
	has_transformed = false
	check_neighbours()
	
	hide_conveyor()
	hide_machine()


func update_visual_to_enter():
	match get_tree().get_first_node_in_group("game_view").current_building_data.building_type:
		Enums.BuildingType.NONE:
			_show_destruction_blueprint()
		Enums.BuildingType.CONVEYOR:
			_show_conveyor_blueprint()
		_: _show_machine_blueprint(get_tree().get_first_node_in_group("game_view").current_building_data)


func _show_destruction_blueprint():
	if !current_building_data.can_be_overwritten: return
	if current_building_data.building_type == Enums.BuildingType.NONE: return
	
	if current_building_data.building_type == Enums.BuildingType.CONVEYOR:
		conveyor.modulate = ColorManager.destroy_color
		return
	
	conveyor.modulate = ColorManager.destroy_color
	machine.modulate = ColorManager.destroy_color


func _show_conveyor_blueprint():
	if !current_building_data.can_be_overwritten: return
	if is_not_empty_or_conveyor(current_building_data): return
	
	machine.visible = false
	
	if current_building_data.building_type == Enums.BuildingType.CONVEYOR:
		conveyor.modulate = ColorManager.existing_build_color
		return
	
	conveyor.modulate = ColorManager.empty_build_color
	conveyor.modulate.a = 1


func _show_machine_blueprint(building_data: BuildingData):
	if !current_building_data.can_be_overwritten: return
	if current_building_data == building_data: return
	
	machine.visible = true
	
	if is_not_empty_or_conveyor(current_building_data):
		machine.set_symbol_texture(building_data.texture_2d, building_data.keep_original_color)
		machine.modulate = ColorManager.existing_build_color
		return
	
	machine.set_symbol_texture(building_data.texture_2d, building_data.keep_original_color)
	machine.modulate = ColorManager.empty_build_color
	machine.modulate.a = 1


func is_not_empty_or_conveyor(building_data: BuildingData) -> bool:
	return building_data.building_type != Enums.BuildingType.NONE && current_building_data.building_type != Enums.BuildingType.CONVEYOR


func update_visual_to_exit():
	hide_conveyor()
	hide_machine()


func hide_conveyor():
	if current_building_data.building_type != Enums.BuildingType.NONE:
		conveyor.modulate = Color.WHITE
		return
	
	conveyor.modulate = Color.WHITE
	conveyor.modulate.a = 0


func hide_machine():
	if current_building_data.building_type != Enums.BuildingType.NONE && current_building_data.building_type != Enums.BuildingType.CONVEYOR:
		if current_building_data.can_be_overwritten:
			machine.set_symbol_texture(current_building_data.texture_2d, current_building_data.keep_original_color)
		machine.modulate = Color.WHITE
		return
	
	machine.modulate = Color.WHITE
	machine.modulate.a = 0


func create_cube():
	match current_building_data.building_type:
		Enums.BuildingType.SPAWNER:
			var new_cube = FactoryManager.get_cube_from_image(cube_image.duplicate()) as BigCube
			add_child(new_cube)
			new_cube.global_position = global_position
			current_cube_array.append(new_cube)


func transform_cube():
	if has_transformed: return
	if current_cube_array.is_empty(): return
	
	match current_building_data.building_type:
		Enums.BuildingType.SPAWNER:
			has_transformed = true
		
		Enums.BuildingType.CONVEYOR:
			has_transformed = true
		
		Enums.BuildingType.DESPAWNER:
			if current_building_data.can_be_overwritten:
				cube_image = current_cube_array[0].current_cube_image
				machine.set_symbol_texture(ImageTexture.create_from_image(cube_image), current_building_data.keep_original_color)
			if current_cube_array[0].compare(cube_image):
				#machine.set_machine_outline(Color.GREEN)
				get_tree().get_first_node_in_group("game_view").building_solved(self)
			else:
				wrong_input_player.play()
				machine.set_machine_outline(Color.RED)
			current_cube_array[0].queue_free()
			current_cube_array.clear()
		
		Enums.BuildingType.EXPANDER:
			current_cube_array[0].expand()
			has_transformed = true
		
		Enums.BuildingType.SHRINKER:
			current_cube_array[0].shrink()
			has_transformed = true
		
		Enums.BuildingType.HORIZONTAL_SQUISHER:
			current_cube_array[0].squish_horizontally()
			has_transformed = true
		
		Enums.BuildingType.VERTICAL_SQUISHER:
			current_cube_array[0].squish_vertically()
			has_transformed = true
		
		Enums.BuildingType.CLOCKWISE_ROTATOR:
			current_cube_array[0].rotate_clockwise()
			has_transformed = true
		
		Enums.BuildingType.COUNTER_CLOCKWISE_ROTATOR:
			current_cube_array[0].rotate_counter_clockwise()
			has_transformed = true
		
		Enums.BuildingType.STACKER:
			if current_cube_array.size() == 2 && !going_toward_array.is_empty():
				var stacked_on_cube = get_inline_current_cube()
				var stacked_cube = get_other_current_cube(stacked_on_cube)
				stacked_on_cube.stack(stacked_cube.current_cube_image)
				stacked_cube.queue_free()
				current_cube_array.remove_at(current_cube_array.find(stacked_cube))
				has_transformed = true
		
		Enums.BuildingType.SPLITTER:
			has_transformed = true
		
		Enums.BuildingType.MERGER:
			has_transformed = true
		
		Enums.BuildingType.SLICER:
			if !coming_from_array.is_empty() && going_toward_array.size() == 3:
				var cut_cube = current_cube_array[0].slice()
				
				var new_cube = FactoryManager.get_cube_from_image(cut_cube[0].duplicate()) as BigCube
				add_child(new_cube)
				new_cube.global_position = global_position
				current_cube_array.append(new_cube)
				
				new_cube = FactoryManager.get_cube_from_image(cut_cube[1].duplicate()) as BigCube
				add_child(new_cube)
				new_cube.global_position = global_position
				current_cube_array.append(new_cube)

				has_transformed = true
		
		Enums.BuildingType.ASSEMBLER:
			if current_cube_array.size() == 3 && coming_from_array.size() == 3 && !going_toward_array.is_empty():
				current_cube_array[0].assemble(current_cube_array[1].current_cube_image, current_cube_array[2].current_cube_image)
				current_cube_array[2].queue_free()
				current_cube_array.remove_at(2)
				current_cube_array[1].queue_free()
				current_cube_array.remove_at(1)
				
				has_transformed = true


func get_other_current_cube(cube: BigCube) -> BigCube:
	for current_cube in current_cube_array:
		if current_cube != cube:
			return current_cube
	return null


func give_to_random_next_going_forward():
	if going_toward_array.is_empty(): return
	
	if !going_toward_array.is_empty() && !current_cube_array.is_empty():
		current_cube_array[0].last_building = self
		going_toward_index = (going_toward_index + 1) % going_toward_array.size()
		if going_toward_array[going_toward_index].add_cube(current_cube_array[0]):
			has_transformed = false


func distribute_all_going_forward():
	if going_toward_array.is_empty(): return
	
	current_cube_array[0].last_building = self
	current_cube_array[1].last_building = self
	current_cube_array[2].last_building = self
	
	going_toward_array[0].add_cube(current_cube_array[0])
	going_toward_array[1].add_cube(current_cube_array[0])
	going_toward_array[2].add_cube(current_cube_array[0])
	
	has_transformed = false


func are_all_cubes_in_position() -> bool:
	for current_cube in current_cube_array:
		if current_cube.global_position != global_position:
			return false
	return true
