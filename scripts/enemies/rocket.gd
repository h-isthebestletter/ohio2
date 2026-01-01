extends EnemySummon2D

var spread: float
var approach_angle: float
var to: Vector2
var speed: float
var damage_player_function: Callable

var from: Vector2

func random_offset(magnitude: float) -> Vector2:
	# create a vector with random length first
	var vec = Vector2(randf_range(0.0, magnitude), 0)
	# then rotate it a random angle
	vec = vec.rotated(randf_range(0.0, TAU))
	return vec

func initialize(args: Dictionary[String, Variant]) -> void:
	spread = args["spread"]
	approach_angle = args["approach_angle"]
	
	var position_offset = random_offset(spread)
	
	from = args["to"] - Vector2(10000.0, 0.0).rotated(approach_angle) + position_offset
	to = args["to"] + position_offset
	speed = args["speed"]
	damage_player_function = args["damage_player_function"]
	
	global_position = from
	rotation = approach_angle
	
func _process(delta: float) -> void:
	global_position += (to - from).normalized() * speed * delta
	
	if (to - global_position).dot(from - global_position) > 0 or to == from:
		detonate()
		return

func detonate() -> void:
	damage_player_function.call()
	request_become_unused.emit(self)
