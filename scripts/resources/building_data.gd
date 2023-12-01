extends Resource
class_name BuildingData


@export var building_type: Enums.BuildingType
@export var texture_2d: Texture2D
@export var keep_original_color: bool = false
@export var coming_from_amount_allowed: int = 1
@export var going_toward_amount_allowed: int = 1
@export var no_in_line_inputs: bool = false

@export var can_be_overwritten: bool = true
