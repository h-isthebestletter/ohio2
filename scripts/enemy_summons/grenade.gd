extends EnemySummon2D

var from: Vector2
var to: Vector2
var speed: float
var atk: int
var attack_speed: float


var internal_position: Vector2
var time := 0.0

func _ready() -> void:
	var to = level.player.global_position
	from = args["from"]
	speed = args["speed"]
	atk = args["atk"]
	attack_speed = args["attack_speed"]
	
	global_position = from
	internal_position = from
	
	var travel_time = (from - to).length() / speed
	var target_extra_displacement = travel_time * level.player.velocity
	to += target_extra_displacement
	
	$AttackWarn.global_position = to


func _process(delta: float) -> void:
	time += delta
	# only fire the grenade after 0.8s
	# (sync with Osama's attack animation)
	if time < 0.8 / attack_speed:
		to = level.player.global_position
		var travel_time = (from - to).length() / speed
		var target_extra_displacement = travel_time * level.player.velocity
		to += target_extra_displacement
		$AttackWarn.global_position = to
		return

	self_modulate = Color.WHITE
	# if projectile has overshot the target position, stop moving
	if (internal_position - from).dot(internal_position - to) > 0:
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
	
	queue_free()
