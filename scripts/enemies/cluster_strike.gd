extends InsignificantEnemy2D

@export var rocket_spread := 330.0
@export_range(0.0, 360.0, 0.001, "degrees") var approach_angle := 150.0
@export var rocket_speed := 3600.0

func update_state_machine() -> void:
	state = State.Attacking

func spawn_rocket() -> void:
	create_summon("res://scenes/components/enemy_summons/rocket.tscn", {
		"spread": rocket_spread,
		"approach_angle": deg_to_rad(approach_angle),
		"to": global_position,
		"speed": rocket_speed,
		"damage_player_function": damage_player
	})

func damage_player() -> void:
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body is Player2D:
			body.take_damage(stats.atk)
			break

func attack() -> void:
	animation_player.play("attacking")
