extends EnemySummon2D

var quadrant: int
var duration: float
var player: Player2D
var target_position: Vector2

var time: float

func initialize(args: Dictionary[String, Variant]) -> void:
	quadrant = args["quadrant"]
	duration = args["duration"]
	player = args["player"]
	target_position = args["position"]
	
	time = 0.0
	
	match quadrant:
		0:
			rotation = 0.5 * PI
		1:
			rotation = PI
		2:
			rotation = 1.5 * PI
		3:
			rotation = 0.0
	
	global_position = target_position
	$ColorRect.material.set_shader_parameter("ADJUSTED_TIME", 0.0)

func _process(delta: float) -> void:
	time += delta
	if time <= 2.0:
		$ColorRect.material.set_shader_parameter("ADJUSTED_TIME", time)
		return
		
	if $Area2D.overlaps_body(player):
		player.receive_status_effect(StatusEffect.Kind.Stunned, INF)
	else:
		player.receive_status_effect(StatusEffect.Kind.Stunned, 0.0)

	if time > duration + 2.0:
		player.receive_status_effect(StatusEffect.Kind.Stunned, 0.0)
		request_become_unused.emit(self)
