extends EnemySummon2D

var spread: float
var approach_angle: float
var to: Vector2
var speed: float
var atk: float

var from: Vector2
var detonated: bool

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
	atk = args["atk"]
	
	$Area2D.global_position = args["to"]
	global_position = from
	rotation = approach_angle
	self_modulate = Color.WHITE
	
	detonated = false
	
func _process(delta: float) -> void:
	if not detonated and ((to - global_position).dot(from - global_position) > 0 or to == from):
		detonate()
	elif not detonated:
		global_position += (to - from).normalized() * speed * delta

func detonate() -> void:
	detonated = true
	self_modulate = Color.TRANSPARENT
	
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Player2D:
			body.take_damage(atk)
			break
	
	$Shockwave.animation_completed.connect(func ():
		request_become_unused.emit(self)
	)
	$Shockwave.start_animation()
