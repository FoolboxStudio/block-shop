extends View


@onready var default_building_data: BuildingData = preload("res://resources/building_data/conveyor.tres")

var current_building_data: BuildingData

@export var level_building_mode: bool
@export var level_building_board_size: Vector2

@onready var level_view:= $PositionControl/VBoxContainer/LevelView as LevelView

@onready var level_design_menu_view:= $PositionControl/Control/LevelDesignMenuView as View
@onready var building_menu_view:= $PositionControl/PanelContainer/BuildingMenuView as View
@onready var level_complete_view:= $PositionControl/LevelCompleteView as View

@onready var level_started_blocking_texture:= $PositionControl/LevelStartedBlockingControl as Control

@export var title_screen_level_data: LevelData
@onready var title_screen:= $PositionControl/TitleScreen as Control

var solved_building: Array[Building]
var building_to_solve: Array[Building]

var hovered_tile: CustomTile

var last_tile: CustomTile
var current_tile: CustomTile

var is_main_screen: bool

var is_level_started: bool

@onready var cpu_particles_2d: CPUParticles2D = $TransitionParticleHolder/CPUParticles2D
@onready var cpu_particles_2d_2: CPUParticles2D = $TransitionParticleHolder/CPUParticles2D2
@onready var cpu_particles_2d_3: CPUParticles2D = $TransitionParticleHolder/CPUParticles2D3
@onready var cpu_particles_2d_4: CPUParticles2D = $TransitionParticleHolder/CPUParticles2D4

@onready var win_stream_player:= $WinStreamPlayer as AudioStreamPlayer2D
@onready var transition_stream_player:= $TransitionStreamPlayer as AudioStreamPlayer2D

@export var level_complete_data: LevelCompleteData
@export var tutorial_complete_data: LevelCompleteData
@export var game_complete_data: LevelCompleteData

var next_level_data: LevelData

@export var normal_mouse_cursor: Texture2D
@export var erase_mouse_cursor: Texture2D


func _ready() -> void:
	current_building_data = default_building_data
	register_input_controller()
	return_to_main_transition()


func set_normal_mouse():
	Input.set_custom_mouse_cursor(normal_mouse_cursor, 0, Vector2(21, 21))


func set_erase_mouse():
	Input.set_custom_mouse_cursor(erase_mouse_cursor, 0, Vector2(21, 21))


func return_to_main():
	set_normal_mouse()
	active_transition_particles()
	var timer = get_tree().create_timer(2.05)
	timer.timeout.connect(return_to_main_transition)


func return_to_main_transition():
	is_main_screen = true
	title_screen.visible = true
	level_complete_view.hide()
	building_menu_view.on_invisible()
	level_view.load_level(title_screen_level_data)
	hovered_tile = null
	start_level()


func switch_to_tutorial():
	active_transition_particles()
	var timer = get_tree().create_timer(2.05)
	timer.timeout.connect(switch_to_tutorial_transition)


func switch_to_tutorial_transition():
	stop_level()
	is_main_screen = false
	title_screen.visible = false
	load_first_tutorial_level()
	start_game()


func switch_to_level():
	active_transition_particles()
	var timer = get_tree().create_timer(2.05)
	timer.timeout.connect(switch_to_level_transition)


func switch_to_level_transition():
	stop_level()
	is_main_screen = false
	title_screen.visible = false
	load_first_level()
	start_game()


#func _process(delta: float) -> void:
#	if Input.is_action_just_pressed("next_level"):
#		load_next_level()


func active_transition_particles():
	transition_stream_player.play()
	ViewManager.block_screen_for(3.75)
	var new_timer = get_tree().create_timer(.75)
	new_timer.timeout.connect(func(): cpu_particles_2d.restart())
	new_timer = get_tree().create_timer(.5)
	new_timer.timeout.connect(func(): cpu_particles_2d_2.restart())
	new_timer = get_tree().create_timer(.25)
	new_timer.timeout.connect(func(): cpu_particles_2d_3.restart())
	cpu_particles_2d_4.restart()


func reset_current_building_data():
	current_building_data = default_building_data


func start_game():
	if level_building_mode: 
		level_view.generate_board(level_building_board_size)
		
		level_design_menu_view.on_visible()
		building_menu_view.on_visible()
		level_view.on_visible()
		return
	
	level_design_menu_view.on_invisible()
	building_menu_view.on_visible()
	level_view.on_visible()


func load_first_tutorial_level():
	building_to_solve.clear()
	next_level_data = LevelManager.get_first_tutorial_level()
	level_view.load_next_level(next_level_data)
	building_menu_view.create_buttons_from_data(next_level_data)


func load_first_level():
	building_to_solve.clear()
	next_level_data = LevelManager.get_first_level()
	level_view.load_next_level(next_level_data)
	building_menu_view.create_buttons_from_data(next_level_data)


func load_next_level():
	building_to_solve.clear()
	next_level_data = LevelManager.get_next_level()
	
	if next_level_data:
		level_view.load_next_level(next_level_data)
		building_menu_view.create_buttons_from_data(next_level_data)
		level_complete_view.transition_invisible()


func increment_building_to_solve(building: Building):
	building_to_solve.append(building)


func _reset() -> void:
	if hovered_tile:
		hovered_tile.building.on_click()
	current_tile = null
	last_tile = null


func _input(event: InputEvent) -> void:
	if event.is_action_released("left_click"):
		_reset()


func handle_last_tile(tile: CustomTile):
	if current_tile == tile: return
	
	last_tile = current_tile
	current_tile = tile
	
	if !last_tile: return

	if tile.building.grid_position.distance_to(last_tile.building.grid_position) > 1: return
	
	if tile.building.allows_coming_from():
		last_tile.building.add_going_toward(tile.building)
	
	if last_tile.building.allows_going_toward():
		tile.building.add_coming_from(last_tile.building)


func set_current_game_tool_to(building_data: BuildingData):
	if hovered_tile:
		hovered_tile.update_visual_to_exit()
	
	current_building_data = building_data
	
	if hovered_tile:
		hovered_tile.update_visual_to_enter()


func toggle_level_started():
	if !is_level_started:
		start_level()
		return
	
	stop_level()


func reset_level():
	building_to_solve.clear()
	level_view.load_next_level(next_level_data)
	building_menu_view.create_buttons_from_data(next_level_data)
	level_complete_view.transition_invisible()


func start_level():
	set_normal_mouse()
	
	level_started_blocking_texture.visible = true
	
	enable_all_buttons()
	reset_current_building_data()
	
	is_level_started = true


func stop_level():
	level_started_blocking_texture.visible = false
	
	for building in building_to_solve:
		building.machine.set_machine_outline(ColorManager.machine_ending_color)
	
	is_level_started = false
	solved_building.clear()
	
	for building in get_tree().get_nodes_in_group("building"):
		building.clear_current_cube()


func enable_all_buttons():
	set_normal_mouse()
	level_design_menu_view.enable_all_buttons()
	building_menu_view.enable_all_buttons()


func building_solved(building: Building):
	if is_main_screen: return
	if solved_building.has(building): return
	
	win_stream_player.play()
	building.machine.set_machine_outline(Color.GREEN)
	solved_building.append(building)
	
	if solved_building.size() < building_to_solve.size(): return
	
	win_level()


func win_level():
	if next_level_data.level_name == "Training 7":
		level_complete_view.update_view(tutorial_complete_data)
	elif next_level_data.level_name == "Level 16":
		level_complete_view.update_view(game_complete_data)
	else:
		level_complete_view.update_view(level_complete_data)
	
	level_complete_view.transition_visible()
	
