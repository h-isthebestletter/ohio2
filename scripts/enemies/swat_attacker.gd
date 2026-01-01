extends Enemy2D
class_name SwatAttacker

@export var attack_range := 800.0
@export var def_boost := 1500.0

func update_state_machine() -> void:
	$RayCast2D.enabled = true
	$RayCast2D.target_position = (player.global_position - global_position).normalized() * attack_range
	$RayCast2D.force_raycast_update()
	if $RayCast2D.get_collider() is Player2D:
		state = State.Attacking
	else:
		state = State.Moving
	
	$RayCast2D.enabled = false

func attack() -> void:
	%Line2D.points[1] = player.global_position - %Line2D.global_position
	if sprite.scale.x == -1.0:
		%Line2D.points[1].x = -%Line2D.points[1].x
	
	player.take_damage(stats.atk)
	animation_player.play("attacking")
	
func take_damage(atk: float) -> void:
	if has_status_effect(StatusEffect.Kind.Invincible):
		# don't take damage when invincible
		return
		
	for body in %TeamingCircle.get_overlapping_bodies():
		if body is SwatDefender:
			health -= max(atk - stats.def - def_boost, 0.0)
			return

	health -= max(atk - stats.def, 0.0)
