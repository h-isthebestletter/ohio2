extends Player2D

@export_category("Skill 1")
@export var skill_1_attack_multiplier := 1.8

@export_category("Skill 2")
@export var retarding_field_duration := 6.0
## Ratio between healing rate in HP/s against total speed of all enemies in pixels/s.
@export var retarding_field_strength := 0.3

func _ready() -> void:
	super()
	attack_animations = [&"attacking_normal", &"skill_1"]
	%BiteOf87SoundEffect.finished.connect(func ():
		%WasThatTheBiteOf87.hide()
	)

func attack() -> void:
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
			body.take_damage(stats.atk * skill_1_attack_multiplier)

func use_skill_2() -> void:
	super()
	create_summon(
		"res://scenes/components/player_summons/retarding_field.tscn",
		{
			"to": global_position,
			"duration": retarding_field_duration,
			"strength": retarding_field_strength,
			"player": self,
			"level": level,
		}
	)

func use_skill_3() -> void:
	super()
	for body in %Skill3AttackHitbox.get_overlapping_bodies():
		if body is Enemy2D:
			# WAS THAT THE BITE OF 87????
			body.receive_status_effect(StatusEffect.Kind.Stunned, INF)
			if body is not Markiplier:
				%WasThatTheBiteOf87.show()
				%BiteOf87SoundEffect.play()
				%BiteSoundEffect.play()
			return
