extends Cube
class_name BigCube


@export var colors: Array[Color]

@export var cube_sprite: Sprite2D

var current_cube_image: Image
var last_building: Building


func set_current_cube_image(cube_image: Image):
	current_cube_image = cube_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func get_random_color() -> Color:
	return colors.pick_random()


func draw_small_cube():
	var random_color = get_random_color()
	for i in 28:
		for j in 28:
			if i >= 12 && i <= 15 && j >= 12 && j <= 15 :
				if i % 3 == 0 || j % 3 == 0:
					current_cube_image.set_pixel(i, j, Color.WEB_GRAY)
				else:
					current_cube_image.set_pixel(i, j, random_color)
			else:
				current_cube_image.set_pixel(i, j, Color.TRANSPARENT)
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func draw_random_medium_cube():
	var random_cuts
	match randi_range(0, 1):
		0: random_cuts = 3
		1: random_cuts = 9
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
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func draw_big_cube():
	var random
	match randi_range(0, 1):
		0: random = 9
		1: random = 27
	var random_color = get_random_color()
	for i in 28:
		for j in 28:
			if i % random == 0 || j % random == 0:
				current_cube_image.set_pixel(i, j, Color.WEB_GRAY)
			else:
				current_cube_image.set_pixel(i, j, random_color)
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func expand():
	if (current_cube_image.get_pixel(14, 0).a != 0 ||
		current_cube_image.get_pixel(27, 14).a != 0 ||
		current_cube_image.get_pixel(14, 27).a != 0 ||
		current_cube_image.get_pixel(0, 14).a != 0): return
	
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var color = current_cube_image.get_pixel(expanding_conversion(i), expanding_conversion(j))
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func expanding_conversion(value: int) -> int:
	if value == 0: return 9
	if value >= 1 && value <= 8: return 10
	if value == 9: return 12
	if value >= 10 && value <= 17: return 13
	if value == 18: return 15
	if value >= 19 && value <= 26: return 16
	if value == 27: return 18
	return -1


func shrink():
	if (current_cube_image.get_pixel(14, 0).a == 0 ||
		current_cube_image.get_pixel(27, 14).a == 0 ||
		current_cube_image.get_pixel(14, 27).a == 0 ||
		current_cube_image.get_pixel(0, 14).a == 0): return
	
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var color
			var x = shrinking_conversion(i)
			var y = shrinking_conversion(j)
			if x == -1 || y == -1:
				color = Color.TRANSPARENT
			else:
				color = current_cube_image.get_pixel(x, y)
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func shrinking_conversion(value: int) -> int:
	if value == 9: return 0
	if value >= 10 && value <= 11:
		return 1 #4 and 7
	if value == 12: return 9
	if value >= 13 && value <= 14:
		return 10 #13 and 16
	if value == 15: return 18
	if value >= 16 && value <= 17:
		return 19 #22 and 25
	if value == 18: return 27
	return -1


func squish_horizontally():
	if current_cube_image.get_pixel(8, 9).a == 0: return
	
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var color
			var x = shrinking_conversion(i)
			if x == -1:
				color = Color.TRANSPARENT
			else:
				color = current_cube_image.get_pixel(x, j)
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func squish_vertically():
	if current_cube_image.get_pixel(9, 8).a == 0: return
	
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var color
			var y = shrinking_conversion(j)
			if y == -1:
				color = Color.TRANSPARENT
			else:
				color = current_cube_image.get_pixel(i, y)
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func rotate_clockwise():
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var width = current_cube_image.get_width() - 1
			var color = current_cube_image.get_pixel(j, width - i)
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func rotate_counter_clockwise():
	var new_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	for i in 28:
		for j in 28:
			var width = current_cube_image.get_width() - 1
			var color = current_cube_image.get_pixel(width - j, i)
			new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func stack(stacked_image: Image):
	var new_image = current_cube_image
	for i in 28:
		for j in 28:
			var color = stacked_image.get_pixel(i, j)
			if color.a != 0:
				new_image.set_pixel(i, j, color)
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func slice() -> Array[Image]:
	var new_top_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	var new_middle_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	var new_bottom_image = Image.create(28, 28, false, Image.FORMAT_RGBA8)
	
	for i in 28:
		for j in 28:
			var color = current_cube_image.get_pixel(i, j)
			if j < 9:
				new_top_image.set_pixel(i, j + 9, color)
			elif j == 9:
				if current_cube_image.get_pixel(i, j - 1).a != 0:
					new_top_image.set_pixel(i, j + 9, Color.WEB_GRAY)
				if current_cube_image.get_pixel(i, j + 1).a != 0:
					new_middle_image.set_pixel(i, j, Color.WEB_GRAY)
			elif j > 9 && j < 18:
				new_middle_image.set_pixel(i, j, color)
			elif j == 18:
				if current_cube_image.get_pixel(i, j - 1).a != 0:
					new_middle_image.set_pixel(i, j, Color.WEB_GRAY)
				if current_cube_image.get_pixel(i, j + 1).a != 0:
					new_bottom_image.set_pixel(i, j - 9, Color.WEB_GRAY)
			elif j > 18:
				new_bottom_image.set_pixel(i, j - 9, color)
	
	current_cube_image = new_middle_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture
	
	return [new_top_image, new_bottom_image]


func assemble(top_image: Image, bottom_image: Image):
	var new_image = current_cube_image
	for i in 28:
		for j in 28:
			var color
			if j < 9:
				color = top_image.get_pixel(i, j + 9)
			elif j == 9:
				color = top_image.get_pixel(i, j + 9)
				if color.a == 0:
					color = current_cube_image.get_pixel(i, j)
			elif j > 9 && j < 18:
				color = current_cube_image.get_pixel(i, j)
			elif j == 18:
				color = current_cube_image.get_pixel(i, j)
				if color.a == 0:
					color = bottom_image.get_pixel(i, j - 9)
			elif j > 18:
				color = bottom_image.get_pixel(i, j - 9)
			new_image.set_pixel(i, j, color)
	
	current_cube_image = new_image
	var new_image_texture = ImageTexture.create_from_image(current_cube_image)
	cube_sprite.texture = new_image_texture


func compare(other_image: Image) -> bool:
	for i in 28:
		for j in 28:
			var current_pixel = current_cube_image.get_pixel(i, j)
			var other_pixel = other_image.get_pixel(i, j)
			if current_pixel != other_pixel:
				if current_pixel.a != 0 || other_pixel.a != 0:
					return false
	return true
