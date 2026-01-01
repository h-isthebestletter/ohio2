extends EnemySummon2D

var from: Vector2
var to: Vector2
var player_velocity: Vector2
var speed: float
var atk: int
var attack_speed: float

var final_target_position
var internal_position: Vector2
var time: float

func aim_ahead(target_position: Vector2, target_velocity: Vector2) -> Vector2:
	var travel_time = (from - to).length() / speed
	var target_extra_displacement = travel_time * player_velocity
	return target_position + target_extra_displacement

func initialize(args: Dictionary[String, Variant]) -> void:
	from = args["from"]
	to = args["to"]
	player_velocity = args["player_velocity"]
	speed = args["speed"]
	atk = args["atk"]
	attack_speed = args["attack_speed"]
	
	global_position = from
	internal_position = from
	final_target_position = null
	time = 0.0
	
	$AttackWarn.global_position = aim_ahead(to, player_velocity)

func _process(delta: float) -> void:
	time += delta
	# only fire the grenade after 0.8s
	# (sync with Osama's attack animation)
	if time < 0.8 / attack_speed:
		$AttackWarn.global_position = aim_ahead(to, player_velocity)
		return
	
	if final_target_position == null:
		final_target_position = aim_ahead(to, player_velocity)

	self_modulate = Color.WHITE
	# if projectile has overshot the target position, stop moving
	if (
		(internal_position - from).dot(internal_position - final_target_position) > 0
		or internal_position == final_target_position
	):
		detonate()
		return

	internal_position += (final_target_position - from).normalized() * speed * delta
	
	var extra_height = (internal_position - from).length() * (internal_position - final_target_position).length() * 0.0005
	global_position = internal_position + Vector2(0, -extra_height)

func detonate() -> void:
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Player2D:
			body.take_damage(atk)
			body.receive_status_effect(StatusEffect.Kind.Poisoned, 5.0, false)
			break
	
	request_become_unused.emit(self)
