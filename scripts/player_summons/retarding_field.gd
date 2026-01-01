extends PlayerSummon2D

var duration: float
var strength: float
var player: Player2D
var level: Level2D
var time: float

func initialize(args: Dictionary[String, Variant]) -> void:
	duration = args["duration"]
	strength = args["strength"]
	player = args["player"]
	level = args["level"]
	
	global_position = args["to"]
	
	time = 0.0

func _process(delta: float) -> void:
	time += delta
	if time > duration:
		for enemy in level.get_all_enemies():
			enemy.receive_status_effect(StatusEffect.Kind.Slowed, 0.0)
			
		request_become_unused.emit(self)
		return
	
	var total_speed := 0.0

	for enemy in level.get_all_enemies():
		if $Area2D.overlaps_body(enemy):
			total_speed += enemy.velocity.length()
			enemy.receive_status_effect(StatusEffect.Kind.Slowed, INF)
		else:
			enemy.receive_status_effect(StatusEffect.Kind.Slowed, 0.0)
	
	player.take_healing(total_speed * strength * delta)
