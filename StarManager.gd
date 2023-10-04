@tool
extends MultiMeshInstance3D


class Star:
	# Position of the star.
	var position: Vector3
	# Luminosity of the star, relative to the luminosity of the Sun. (L☉)
	var luminosity: float
	# Temperature of the star, in kelvin.
	var temperature: float

	func _init(position: Vector3, luminosity: float, temperature: float):
		self.position = position
		self.luminosity = luminosity
		self.temperature = temperature


var _rebuild_instances = true
var _star_list: Array[Star] = []


func set_star_list(star_list: Array[Star]):
	_rebuild_instances = true
	_star_list = star_list


func blackbody_to_rgb(kelvin):
	var temperature = kelvin / 100.0
	var red
	var green
	var blue

	if temperature < 66.0:
		red = 255
	else:
		# a + b x + c Log[x] /.
		# {a -> 351.97690566805693`,
		# b -> 0.114206453784165`,
		# c -> -40.25366309332127
		#x -> (kelvin/100) - 55}
		red = temperature - 55.0
		red = 351.97690566805693 + 0.114206453784165 * red - 40.25366309332127 * log(red)
		if red < 0:
			red = 0
		if red > 255:
			red = 255

	# Calculate green

	if temperature < 66.0:
		# a + b x + c Log[x] /.
		# {a -> -155.25485562709179`,
		# b -> -0.44596950469579133`,
		# c -> 104.49216199393888`,
		# x -> (kelvin/100) - 2}
		green = temperature - 2
		green = (
			-155.25485562709179
			- 0.44596950469579133 * green
			+ 104.49216199393888 * log(green)
		)
		if green < 0:
			green = 0
		if green > 255:
			green = 255

	else:
		# a + b x + c Log[x] /.
		# {a -> 325.4494125711974`,
		# b -> 0.07943456536662342`,
		# c -> -28.0852963507957`,
		# x -> (kelvin/100) - 50}
		green = temperature - 50.0
		green = 325.4494125711974 + 0.07943456536662342 * green - 28.0852963507957 * log(green)
		if green < 0:
			green = 0
		if green > 255:
			green = 255

	# Calculate blue

	if temperature >= 66.0:
		blue = 255
	else:
		if temperature <= 20.0:
			blue = 0
		else:
			# a + b x + c Log[x] /.
			# {a -> -254.76935184120902`,
			# b -> 0.8274096064007395`,
			# c -> 115.67994401066147`,
			# x -> kelvin/100 - 10}
			blue = temperature - 10
			blue = (
				-254.76935184120902
				+ 0.8274096064007395 * blue
				+ 115.67994401066147 * log(blue)
			)
			if blue < 0:
				blue = 0
			if blue > 255:
				blue = 255

	return Color(red / 255.0, green / 255.0, blue / 255.0)


func _process(_delta):
	if not _rebuild_instances:
		return

	_rebuild_instances = false
	# Throws an error when trying to set properties otherwise.
	multimesh.instance_count = 0
	multimesh.use_colors = true
	multimesh.use_custom_data = true
	multimesh.instance_count = _star_list.size()

	for i in range(_star_list.size()):
		var star = _star_list[i]
		var transform = Transform3D().translated(star.position)
		multimesh.set_instance_transform(i, transform)
		multimesh.set_instance_color(i, blackbody_to_rgb(star.temperature))
		multimesh.set_instance_custom_data(i, Color(star.luminosity, 0, 0))
