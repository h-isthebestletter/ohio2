extends PlayerSummon2D

var target: Enemy2D
var from: Vector2
var to: Vector2
var speed: float
var atk: float

var hit: bool

func initialize(args: Dictionary[String, Variant]) -> void:
	target = args["target"]
	from = args["from"]
	to = args["to"]
	speed = args["speed"]
	atk = args["atk"]
	
	hit = false
	global_position = from

func _process(delta: float) -> void:
	var displacement = (to - from).normalized() * delta * speed
	global_position += displacement
	
	if not hit and (global_position - to).dot(global_position - from) > 0.0:
		if target != null:
			target.take_damage(atk)
		hit = true
		request_become_unused.emit(self)
