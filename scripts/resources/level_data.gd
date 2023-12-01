extends Resource
class_name LevelData


@export var level_name: String
@export var board_size: Vector2
@export var custom_tile_data_array: Array[CustomTileData]
@export var available_building: Array[Enums.BuildingType]

@export_multiline var hint: String
