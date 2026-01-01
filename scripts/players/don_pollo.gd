extends Player2D

@export_category("Normal attack")
@export var chicken_throw_speed := 5000.0

@export_category("Skill 1")
@export var skill_1_movement_speed_multiplier := 2.0
@export var skill_1_duration := 30.0

@export_category("Skill 3")
## How long Destreza should last when it is first used.
## When it is used the second time, the effect lasts forever.
@export var destreza_first_time_duration := 20.0

var target: Enemy2D

var original_base_movement_speed: float

var times_used_destreza := 0
var original_base_atk: float
var original_base_attack_speed: float

func _ready() -> void:
	super()
	original_base_movement_speed = base_stats.movement_speed
	original_base_atk = base_stats.atk
	original_base_attack_speed = base_stats.attack_speed
	attack_animations = [&"attacking_normal_melee", &"attacking_normal_ranged"]

func _process(delta: float) -> void:
	super(delta)
	if is_skill_active(1):
		base_stats.movement_speed = original_base_movement_speed * skill_1_movement_speed_multiplier
	else:
		base_stats.movement_speed = original_base_movement_speed

	if times_used_destreza == 1:
		%NormalAttackRangeIndicator.hide()
		%DestrezaAttackRangeIndicator.show()
		if is_skill_active(3):
			base_stats.atk = original_base_atk * 1.6
			base_stats.attack_speed = original_base_attack_speed * 1.25
		else:
			%NormalAttackRangeIndicator.show()
			%DestrezaAttackRangeIndicator.hide()
			base_stats.atk = original_base_atk
			base_stats.attack_speed = original_base_attack_speed
	elif times_used_destreza == 2:
		%NormalAttackRangeIndicator.hide()
		%DestrezaAttackRangeIndicator.show()
		base_stats.atk = original_base_atk * 2.2
		base_stats.attack_speed = original_base_attack_speed * 1.5

func _input(event: InputEvent) -> void:
	if state != State.ALIVE: return
	if animation_player.is_playing() and animation_player.current_animation in attack_animations:
		return
		
	if Input.is_action_just_pressed("player_attack"):
		if not has_status_effect(StatusEffect.Kind.Stunned):
			attack()
	
	if Input.is_action_just_pressed("player_use_skill_1"):
		if not is_skill_active(1) and can_afford_skill(1):
			if not has_status_effect(StatusEffect.Kind.Stunned):
				skill_points -= skills_sp_cost[0]
				use_skill_1()
	
	# override skill 2: don pollo can use it even when stunned
	if Input.is_action_just_pressed("player_use_skill_2"):
		if not is_skill_active(2) and can_afford_skill(2):
			skill_points -= skills_sp_cost[1]
			use_skill_2()
	
	if Input.is_action_just_pressed("player_use_skill_3"):
		if not is_skill_active(3) and can_afford_skill(3):
			if not has_status_effect(StatusEffect.Kind.Stunned):
				skill_points -= skills_sp_cost[2]
				use_skill_3()

func attack() -> void:
	var is_attack_melee := false
	
	target = null
	
	for body in %MeleeNormalAttackHitbox.get_overlapping_bodies():
		if body is Enemy2D:
			is_attack_melee = true
	
	if not is_attack_melee:
		for body in %RangedNormalAttackHitbox.get_overlapping_bodies():
			if target == null and body is Enemy2D:
				target = body
	
	# has destreza
	if not is_attack_melee and target == null and is_skill_active(3):
		for body in %DestrezaHitbox.get_overlapping_bodies():
			if target == null and body is Enemy2D:
				target = body
	
	if is_attack_melee:
		animation_player.play("attacking_normal_melee")
	else:
		animation_player.play("attacking_normal_ranged")

func melee_attack_deal_damage() -> void:
	for body in %MeleeNormalAttackHitbox.get_overlapping_bodies():
		if body is Enemy2D:
			body.take_damage(stats.atk)

func ranged_attack_create_summon() -> void:
	var atk_multiplier: float
	# has destreza
	if is_skill_active(3):
		atk_multiplier = 1.0
	else:
		atk_multiplier = 0.8
	
	var target_position: Vector2
	if target == null:
		target_position = global_position + Vector2(10000.0, 0.0).rotated(attack_direction)
	else:
		target_position = target.global_position
	
	create_summon(
		"res://scenes/components/player_summons/fried_chicken.tscn",
		{
			"from": global_position,
			"to": target_position,
			"target": target,
			"speed": chicken_throw_speed,
			"atk": stats.atk * atk_multiplier
		}
	)

func use_skill_1() -> void:
	super()
	set_skill_duration(1, skill_1_duration)

func use_skill_2() -> void:
	super()
	receive_status_effect(StatusEffect.Kind.Slowed, 0.0, true)
	receive_status_effect(StatusEffect.Kind.Poisoned, 0.0, true)
	receive_status_effect(StatusEffect.Kind.Stunned, 0.0, true)
	receive_status_effect(StatusEffect.Kind.Frozen, 0.0, true)
	
	for summon: EnemySummon2D in level.get_all_enemy_summons():
		summon.request_become_unused.emit(summon)
	
func use_skill_3() -> void:
	super()
	if times_used_destreza == 0:
		set_skill_duration(3, destreza_first_time_duration)
	else:
		set_skill_duration(3, INF)
		
	times_used_destreza += 1
