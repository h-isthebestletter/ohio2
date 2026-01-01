extends Enemy2D

func update_state_machine() -> void:
	if state == State.Attacking:
		state = State.Moving
	elif state == State.Moving:
		state = State.Attacking
	elif state == State.Spawning:
		state = State.Attacking

func attack() -> void:
	animation_player.play("attacking")
	create_summon("res://scenes/components/enemy_summons/evocator_fireball.tscn", {
		"from": global_position,
		"target": player,
		"speed": 700.0,
		"atk": stats.atk,
	})
