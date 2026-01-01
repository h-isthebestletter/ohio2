extends Enemy2D

@export var attack_range := 60.0

func update_state_machine() -> void:
	if player.global_position.distance_to(global_position) < attack_range:
		state = State.Attacking
	else:
		state = State.Moving

func deal_damage() -> void:
	player.take_damage(stats.atk)

func attack() -> void:
	animation_player.play("attacking")
