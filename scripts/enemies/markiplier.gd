extends Enemy2D
class_name Markiplier

func update_state_machine() -> void:
	if player.global_position.distance_to(global_position) < 60.0:
		state = State.Attacking
	else:
		state = State.Moving

func deal_damage() -> void:
	player.take_damage(stats.atk)

func attack() -> void:
	animation_player.play("attacking")
