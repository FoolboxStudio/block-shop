extends Sprite2D
class_name Machine


@onready var machine_symbol:= $MachineSymbol as Sprite2D

@onready var north_door_visual: = $NorthDoor/DoorVisual as Sprite2D
@onready var south_door_visual:= $SouthDoor/DoorVisual as Sprite2D
@onready var west_door_visual:= $WestDoor/DoorVisual as Sprite2D
@onready var east_door_visual:= $EastDoor/DoorVisual as Sprite2D

@onready var north_conveyor_visual: = $NorthDoor/ConveyorVisual as AnimatedSprite2D
@onready var south_conveyor_visual:= $SouthDoor/ConveyorVisual as AnimatedSprite2D
@onready var west_conveyor_visual:= $WestDoor/ConveyorVisual as AnimatedSprite2D
@onready var east_conveyor_visual:= $EastDoor/ConveyorVisual as AnimatedSprite2D

@onready var machine_outline:= $MachineOutline as Sprite2D


func start_animation():
	north_conveyor_visual.play()
	south_conveyor_visual.play()
	west_conveyor_visual.play()
	east_conveyor_visual.play()


func stop_animation():
	north_conveyor_visual.stop()
	south_conveyor_visual.stop()
	west_conveyor_visual.stop()
	east_conveyor_visual.stop()


func set_symbol_texture(texture_2d: Texture2D, keep_original_color: bool):
	machine_symbol.texture = texture_2d
	
	if keep_original_color:
		machine_symbol.modulate = Color.WHITE
	else:
		machine_symbol.modulate = ColorManager.machine_symbol_color


func set_machine_outline(outline_color: Color):
	machine_outline.visible = true
	machine_outline.modulate = outline_color


func update_doors_visual(going_toward_array: Array[Building], coming_from_array: Array[Building], grid_position: Vector2):
	north_door_visual.modulate = ColorManager.machine_normal_color
	south_door_visual.modulate = ColorManager.machine_normal_color
	west_door_visual.modulate = ColorManager.machine_normal_color
	east_door_visual.modulate = ColorManager.machine_normal_color
	
	north_conveyor_visual.modulate.a = 0
	south_conveyor_visual.modulate.a = 0
	west_conveyor_visual.modulate.a = 0
	east_conveyor_visual.modulate.a = 0
	
	for going_toward in going_toward_array:
		match (going_toward.grid_position - grid_position).normalized():
			Vector2.UP:
				north_door_visual.modulate = ColorManager.machine_going_toward_color
				set_conveyor_animation_to(north_conveyor_visual, "door_out")
			Vector2.DOWN:
				south_door_visual.modulate = ColorManager.machine_going_toward_color
				set_conveyor_animation_to(south_conveyor_visual, "door_out")
			Vector2.LEFT:
				west_door_visual.modulate = ColorManager.machine_going_toward_color
				set_conveyor_animation_to(west_conveyor_visual, "door_out")
			Vector2.RIGHT:
				east_door_visual.modulate = ColorManager.machine_going_toward_color
				set_conveyor_animation_to(east_conveyor_visual, "door_out")
	
	for coming_from in coming_from_array:
		match (coming_from.grid_position - grid_position).normalized():
			Vector2.UP:
				north_door_visual.modulate = ColorManager.machine_coming_from_color
				set_conveyor_animation_to(north_conveyor_visual, "door_in")
			Vector2.DOWN:
				south_door_visual.modulate = ColorManager.machine_coming_from_color
				set_conveyor_animation_to(south_conveyor_visual, "door_in")
			Vector2.LEFT:
				west_door_visual.modulate = ColorManager.machine_coming_from_color
				set_conveyor_animation_to(west_conveyor_visual, "door_in")
			Vector2.RIGHT:
				east_door_visual.modulate = ColorManager.machine_coming_from_color
				set_conveyor_animation_to(east_conveyor_visual, "door_in")


func set_conveyor_animation_to(animated_sprite_2d: AnimatedSprite2D, animation: String):
	var animation_frame = animated_sprite_2d.frame
	var progress = animated_sprite_2d.frame_progress
	animated_sprite_2d.animation = animation
	animated_sprite_2d.set_frame_and_progress(animation_frame, progress)
	animated_sprite_2d.modulate.a = 1
