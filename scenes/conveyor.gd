extends AnimatedSprite2D
class_name Conveyor


func redirect_toward(direction: Vector2):
	look_at(global_position + direction)


func start_animation():
	play()


func stop_animation():
	stop()


func update_conveyor_animation(going_toward_array: Array[Building], coming_from_array: Array[Building], grid_position: Vector2):
	var animation_state = get_animation_state(going_toward_array, coming_from_array, grid_position)
	var animation_frame = frame
	var progress = frame_progress
	animation = animation_state
	set_frame_and_progress(animation_frame, progress)


func get_animation_state(going_toward_array: Array[Building], coming_from_array: Array[Building], grid_position: Vector2) -> String:
	if coming_from_array.is_empty() && !going_toward_array.is_empty():
		redirect_toward((going_toward_array[0].grid_position - grid_position).normalized())
		return "start"
	elif coming_from_array.is_empty() && going_toward_array.is_empty():
		return "default"
	elif !coming_from_array.is_empty() && going_toward_array.is_empty():
		redirect_toward((grid_position - coming_from_array[0].grid_position).normalized())
		return "end"
	else:
		var coming_from_direction = grid_position - coming_from_array[0].grid_position
		var going_toward_direction = going_toward_array[0].grid_position - grid_position
		if abs(going_toward_direction.x - coming_from_direction.x) < 0.001 && abs(going_toward_direction.y - coming_from_direction.y) < 0.001:
			redirect_toward((going_toward_array[0].grid_position - grid_position).normalized())
			return "continue"
		elif going_toward_direction.angle_to(coming_from_direction) < 0:
			redirect_toward((going_toward_array[0].grid_position - grid_position).normalized())
			return "turn_right"
		elif going_toward_direction.angle_to(coming_from_direction) > 0:
			redirect_toward((going_toward_array[0].grid_position - grid_position).normalized())
			return "turn_left"
	return "default"
