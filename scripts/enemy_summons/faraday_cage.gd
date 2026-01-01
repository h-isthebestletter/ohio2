extends EnemySummon2D

var duration: float
var time: float
var player: Player2D
var strength: float

func initialize(args: Dictionary[String, Variant]) -> void:
	time = 0.0
	duration = args["duration"]
	global_position = args["to"]
	player = args["player"]
	strength = args["strength"]

func _process(delta: float) -> void:
	time += delta
	if time > duration:
		request_become_unused.emit(self)
		return
	
	if not $Area2D.overlaps_body(player):
		# subtract health directly, because DEF reduction will mitigate
		# constant small HP decrease entirely.
		player.health -= strength * delta
		$Line2D.points[1] = player.global_position - position
	else:
		$Line2D.points[1] = Vector2.ZERO
