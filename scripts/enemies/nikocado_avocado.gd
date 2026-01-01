extends Enemy2D

func update_state_machine() -> void:
	if player.global_position.distance_to(global_position) < 2300:
		state = State.Attacking
	else:
		state = State.Moving

func deal_damage() -> void:
	%Shockwave.start_animation()
	for body in $Area2D.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(stats.atk)
			return

func attack() -> void:
	animation_player.play("attacking")
