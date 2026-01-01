extends Enemy2D

@export var range := 600.0

func update_state_machine() -> void:
	$RayCast2D.enabled = true
	$RayCast2D.target_position = (player.global_position - global_position).normalized() * range
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
