extends PlayerSummon2D

var duration: float

func initialize(args: Dictionary[String, Variant]) -> void:
	duration = args["effect_duration"]
	global_position = args["to"]

func _process(delta: float) -> void:
	for body in $Area2D.get_overlapping_bodies():
		if body is Enemy2D:
			body.receive_status_effect(StatusEffect.Kind.Poisoned, duration, false)
			body.receive_status_effect(StatusEffect.Kind.Slowed, duration, false)
			request_become_unused.emit(self)
			return
