extends Node


@onready var packed_big_cube = preload("res://scenes/cubes/big_cube.tscn")

@export var colors: Array[Color]


func get_random_color() -> Color:
	return colors.pick_random()


func get_random_cube() -> BigCube:
	var new_cube = packed_big_cube.instantiate() as BigCube
	new_cube.set_current_cube_image(draw_random_medium_cube())
	get_tree().root.add_child(new_cube)
	return new_cube


func get_cube_from_image(image: Image) -> BigCube:
	var new_cube = packed_big_cube.instantiate() as BigCube
	new_cube.set_current_cube_image(image)
	#get_tree().root.add_child(new_cube)
	return new_cube


func draw_random_medium_cube() -> Image:
	var current_cube_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	var random_cuts = 9
	var random_color = get_random_color()
	for i in 28:
		for j in 28:
			if random_cuts == 3 && (i - 1) % random_cuts == 0 && (j - 1) % random_cuts == 0:
				random_color = get_random_color()
			if i >= 9 && i <= 18 && j >= 9 && j <= 18 :
				if i % random_cuts == 0 || j % random_cuts == 0:
					current_cube_image.set_pixel(i, j, Color.WEB_GRAY)
				elif (i + 1) % random_cuts == 0:
					var color = current_cube_image.get_pixel(i - 1, j)
					current_cube_image.set_pixel(i, j, color)
				elif (j + 1) % random_cuts == 0:
					var color = current_cube_image.get_pixel(i, j - 1)
					current_cube_image.set_pixel(i, j, color)
				else:
					current_cube_image.set_pixel(i, j, random_color)
			else:
				current_cube_image.set_pixel(i, j, Color.TRANSPARENT)
	return current_cube_image
