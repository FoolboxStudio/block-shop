extends InputController


func process_inputs():
	if get_tree().get_first_node_in_group("game_view").is_level_started: return
	
	var index: int = -1
	if Input.is_action_just_pressed("1"): index = 0
	elif Input.is_action_just_pressed("2"): index = 1
	elif Input.is_action_just_pressed("3"): index = 2
	elif Input.is_action_just_pressed("4"): index = 3
	elif Input.is_action_just_pressed("5"): index = 4
	elif Input.is_action_just_pressed("6"): index = 5
	elif Input.is_action_just_pressed("7"): index = 6
	elif Input.is_action_just_pressed("8"): index = 7
	elif Input.is_action_just_pressed("9"): index = 8
	elif Input.is_action_just_pressed("0"): index = 9
	
	if index != -1:
		SignalManager.switch_game_tool_menu_to.emit(index)
