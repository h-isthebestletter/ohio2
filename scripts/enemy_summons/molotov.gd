extends EnemySummon2D

var from: Vector2
var to: Vector2
var player_velocity: Vector2
var speed: float
var atk: int
var attack_speed: float

var internal_position: Vector2
var time: float

func initialize(args: Dictionary[String, Variant]) -> void:
	from = args["from"]
	to = args["to"]
	player_velocity = args["player_velocity"]
	speed = args["speed"]
	atk = args["atk"]
	attack_speed = args["attack_speed"]
	
	global_position = from
	internal_position = from
	time = 0.0
	

func _process(delta: float) -> void:
	# if projectile has overshot the target position, stop moving
	if (
		(internal_position - from).dot(internal_position - to) > 0
		or internal_position == to
	):
		detonate()
		return

	internal_position += (to - from).normalized() * speed * delta
	
	var extra_height = (internal_position - from).length() * (internal_position - to).length() * 0.0005
	global_position = internal_position + Vector2(0, -extra_height)

func detonate() -> void:
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Player2D:
			body.take_damage(atk)
			break
	
	request_become_unused.emit(self)
