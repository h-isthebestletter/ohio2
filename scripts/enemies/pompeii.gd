extends Enemy2D

@export var attack_range := 600.0

func update_state_machine() -> void:
	if (global_position - target_position).length() <= attack_range:
		state = State.Attacking
	else:
		state = State.Moving

func attack() -> void:
	animation_player.play("attacking")
	create_summon("res://scenes/components/enemy_summons/pompeii_fireball.tscn", {
		"from": global_position,
		"to": target_position,
		"player_velocity": target_velocity,
		"speed": 800.0,
		"atk": stats.atk,
		"attack_speed": stats.attack_speed,
	})
