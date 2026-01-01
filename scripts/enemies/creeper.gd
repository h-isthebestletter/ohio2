extends Enemy2D

func update_state_machine() -> void:
	for body in $ExplosionArea2D.get_overlapping_bodies():
		if body is Player2D:
			state = State.Attacking
			return

	state = State.Moving

func attack() -> void:
	animation_player.play("attacking")
	for body in $ExplosionArea2D.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(self.stats.atk)
			health = 0.0
			Signals.entity_died.emit(self)
			return
