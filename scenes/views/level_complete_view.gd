extends View


@onready var complete_text:= $PositionControl/PanelContainer/VBoxContainer/CompleteText as RichTextLabel
@onready var extra_text:= $PositionControl/PanelContainer/VBoxContainer/ExtraText as Label
@onready var custom_button:= $PositionControl/PanelContainer/VBoxContainer/HBoxContainer/CustomButton as CustomButton


func update_view(level_complete_data: LevelCompleteData):
	extra_text.hide()
	
	complete_text.text = level_complete_data.complete_string
	if level_complete_data.extra_string != "":
		extra_text.show()
		extra_text.text = level_complete_data.extra_string
	custom_button.command = level_complete_data.click_command
	custom_button.text = level_complete_data.button_text
	custom_button.custom_minimum_size.x = level_complete_data.button_width
