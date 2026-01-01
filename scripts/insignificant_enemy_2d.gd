extends Enemy2D
class_name InsignificantEnemy2D

func _set_health(val: float) -> void:
	# remove health_related signals
	if val < 0:
		health = 0
	else:
		health = min(stats.max_health, val)

func take_damage(atk: float) -> void:
	# insignificant enemies are invulnerable
	pass
