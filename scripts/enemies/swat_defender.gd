extends Enemy2D
class_name SwatDefender

@export var atk_boost := 400.0

func update_state_machine() -> void:
	if player.global_position.distance_to(global_position) < 60.0:
		state = State.Attacking
	else:
		state = State.Moving

func deal_damage() -> void:
	for body in %TeamingCircle.get_overlapping_bodies():
		if body is SwatAttacker:
			player.take_damage(stats.atk + atk_boost)
			return
	
	player.take_damage(stats.atk)

func attack() -> void:
	animation_player.play("attacking")
