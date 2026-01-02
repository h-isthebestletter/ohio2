extends EnemySummon2D

var approach_angle: float
var to: Vector2
var speed: float
var atk: float

var from: Vector2
var time: float
var detonated: bool

func initialize(args: Dictionary[String, Variant]) -> void:
	approach_angle = args["approach_angle"]

	to = args["to"]
	speed = args["speed"]
	atk = args["atk"]
	
	from = args["to"] - Vector2(10000.0, 0.0).rotated(approach_angle)
	time = 0.0
	
	self_modulate = Color.TRANSPARENT
	global_position = from
	rotation = approach_angle
	detonated = false
	$ShockwaveLarge.global_position = to
	$ShockwaveLarge.stop_animation()
	$AttackWarn.global_position = to
	$Area2D.global_position = to
	
func _process(delta: float) -> void:
	time += delta
	# sync with attack animation
	if detonated or time < 1.2: return
	self_modulate = Color.WHITE
	global_position += (to - from).normalized() * speed * delta
	
	if (to - global_position).dot(from - global_position) > 0 or to == from:
		detonate()
		return

func detonate() -> void:
	if detonated: return
	detonated = true
	
	self_modulate = Color.TRANSPARENT
	
	$ShockwaveLarge.start_animation()
	$ShockwaveLarge.animation_completed.connect(func ():
		request_become_unused.emit(self)
	)
	
	for body in $Area2D.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(atk)
			break
