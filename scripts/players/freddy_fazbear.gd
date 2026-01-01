extends Player2D

#func _ready() -> void:
	#super()
	#receive_status_effect(StatusEffect.Kind.Invincible, INF)

func attack() -> void:
	super()
	animation_player.play("attacking_normal")

func normal_attack_deal_damage() -> void:
	for body in %NormalAttackHitbox.get_overlapping_bodies():
		if body is Enemy2D:
			body.take_damage(stats.atk)

func use_skill_1() -> void:
	super()
	animation_player.play("skill_1")

func skill_1_effect() -> void:
	# raycast to find appropriate point to dash to
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2.from_angle(attack_direction) * 300.0,
		1
	)
	var result = space_state.intersect_ray(query).get("position")
	if result != null:
		global_position = result
	else:
		global_position += Vector2.from_angle(attack_direction) * 300.0

	for body in %Skill1AttackHitbox.get_overlapping_bodies():
		if body is Enemy2D:
			body.take_damage(stats.atk * 1.8)

func use_skill_2() -> void:
	super()

func use_skill_3() -> void:
	super()
