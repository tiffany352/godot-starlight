@tool
extends "res://addons/starlight/StarManager.gd"
## Procedurally generates main sequence stars and populates StarManager with them.

## Radius of a sphere in which to place stars.
@export var size: float = 5000: set = _set_extents
## Number of stars to generate.
@export var star_count: int = 10000: set = _set_star_count
## RNG seed, which can be used to re-roll the random generation.
@export var rng_seed: int = 1234: set = _set_rng_seed
## If set to true, a Sol-like star will be placed at 0,0,0.
@export var generate_at_origin: bool = false: set = _set_generate_at_origin


var _regenerate = true


func _set_extents(value):
	size = value
	_regenerate = true


func _set_star_count(value):
	star_count = value
	_regenerate = true


func _set_rng_seed(value):
	rng_seed = value
	_regenerate = true


func _set_generate_at_origin(value):
	generate_at_origin = value
	_regenerate = true


class RangeF:
	var min: float
	var max: float

	func _init(min: float, max: float):
		self.min = min
		self.max = max

	func sample(value: float):
		return (max - min) * value + min


class StarClass:
	var weight: int
	var stellar_class: String
	var temp_range: RangeF
	var luminosity_range: RangeF
	var mass_range: RangeF

	func _init(dict: Dictionary):
		self.weight = dict.weight
		self.stellar_class = dict.stellar_class
		self.temp_range = dict.temp_range
		self.luminosity_range = dict.luminosity_range
		self.mass_range = dict.mass_range

	func sample(value: float):
		return {
			stellar_class = stellar_class,
			temp = temp_range.sample(value),
			luminosity = luminosity_range.sample(value),
			mass = mass_range.sample(value),
		}

	func get_star(position: Vector3, value: float):
		var p = self.sample(value)
		# B and O-class stars are obscenely bright, so spawn them further away than other stars.
		position *= max(1.0, p.luminosity / 400)
		return Star.new(position, p.luminosity, p.temp)


var class_O = StarClass.new({
	weight = 1,
	stellar_class = "O",
	temp_range = RangeF.new(30_000, 60_000),
	luminosity_range = RangeF.new(30_000, 60_000),
	mass_range = RangeF.new(16, 32),
})
var class_B = StarClass.new({
	weight = 13,
	stellar_class = "B",
	temp_range = RangeF.new(10_000, 30_000),
	luminosity_range = RangeF.new(25, 30_000),
	mass_range = RangeF.new(2.1, 16),
})
var class_A = StarClass.new({
	weight = 60,
	stellar_class = "A",
	temp_range = RangeF.new(7500, 10_000),
	luminosity_range = RangeF.new(5, 25),
	mass_range = RangeF.new(1.4, 2.1),
})
var class_F = StarClass.new({
	weight = 3_00,
	stellar_class = "F",
	temp_range = RangeF.new(6000, 7500),
	luminosity_range = RangeF.new(1.5, 5),
	mass_range = RangeF.new(1.04, 1.4),
})
var class_G = StarClass.new({
	weight = 7_60,
	stellar_class = "G",
	temp_range = RangeF.new(5200, 6000),
	luminosity_range = RangeF.new(.6, 1.50),
	mass_range = RangeF.new(0.8, 1.04),
})
var class_K = StarClass.new({
	weight = 12_10,
	stellar_class = "K",
	temp_range = RangeF.new(3700, 5200),
	luminosity_range = RangeF.new(0.08, 0.6),
	mass_range = RangeF.new(0.45, 0.8),
})
var class_M = StarClass.new({
	weight = 76_45,
	stellar_class = "M",
	temp_range = RangeF.new(2400, 3700),
	luminosity_range = RangeF.new(0.1, 0.08),
	mass_range = RangeF.new(0.08, 0.45),
})


var star_table = [
	class_O,
	class_B,
	class_A,
	class_F,
	class_G,
	class_K,
	class_M,
]


func sample_sphere(rng: RandomNumberGenerator, radius: float):
	while true:
		var pos = Vector3(
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0),
			rng.randf_range(-1.0, 1.0)
		)
		if pos.length_squared() <= 1.0:
			return pos * radius


func random_category(rng: RandomNumberGenerator):
	var sum = 0
	for category in star_table:
		sum += category.weight;

	var weight = rng.randi_range(1, sum - 1)

	sum = 0
	for category in star_table:
		var prev = sum
		sum += category.weight;
		if weight <= sum:
			return category


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _regenerate:
		return

	_regenerate = false

	var rng = RandomNumberGenerator.new()
	rng.seed = rng_seed

	var stars: Array[Star] = []

	if generate_at_origin:
		stars.push_back(class_G.get_star(Vector3.ZERO, 0.5))

	for i in range(0, star_count):
		var category = random_category(rng)
		if not category:
			continue

		stars.push_back(category.get_star(sample_sphere(rng, size), rng.randf()))

	set_star_list(stars)

	super._process(delta)
