extends EnemySummon2D

var from: Vector2
var target: Player2D
var speed: float
var atk: float

var time_activated: float

func initialize(args: Dictionary[String, Variant]) -> void:
	from = args["from"]
	target = args["target"]
	speed = args["speed"]
	atk = args["atk"]
	
	time_activated = 0.0
	global_position = from

func _process(delta: float) -> void:
	time_activated += delta
	if time_activated > 60.0:
		request_become_unused.emit(self)
		return

	$NavigationAgent2D.target_position = target.global_position
	global_position += (
		$NavigationAgent2D.get_next_path_position() - global_position
	).normalized() * speed * delta
	
	for body in $Area2D.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(atk)
			request_become_unused.emit(self)
			return
