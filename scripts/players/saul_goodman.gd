extends Player2D

@export_category("Normal attack")
@export var dash_distance := 200.0

@export_category("Skill 1")
@export var skill_1_freeze_duration := 4.0
## How many SP to generate per second
@export var skill_1_sp_generation_rate := 3.0
@export var skill_1_duration := 4.0

@export_category("Skill 2")
## How long (in seconds) the effects of consuming the crystal will last
@export var skill_2_effect_duration := 10.0

@export_category("Skill 3")
@export var skill_3_atk_multiplier := 1.8

var skill_1_time := INF
var skill_1_receive_sp_time := INF

func _ready() -> void:
	super()
	attack_animations = [&"attacking_normal"]

func _process(delta: float) -> void:
	super(delta)
	skill_1_time += delta
	skill_1_receive_sp_time += delta
	if skill_1_time < skill_1_duration:
		if skill_1_receive_sp_time > (1 / skill_1_sp_generation_rate):
			skill_points += 1
			skill_1_receive_sp_time = 0.0

func attack() -> void:
	animation_player.play("attacking_normal")

func normal_attack_damage_enemy() -> void:
	for enemy in %NormalAttackHitbox.get_overlapping_bodies():
		if enemy is Enemy2D:
			enemy.take_damage(stats.atk)
			return

func use_skill_1() -> void:
	super()
	skill_1_time = 0.0
	receive_status_effect(StatusEffect.Kind.Frozen, skill_1_freeze_duration)

func use_skill_2() -> void:
	super()
	create_summon(
		"res://scenes/components/player_summons/crystal.tscn",
		{
			"to": global_position,
			"effect_duration": skill_2_effect_duration,
		}
	)

func use_skill_3() -> void:
	super()
	create_summon(
		"res://scenes/components/player_summons/exploding_crystal.tscn",
		{
			"to": global_position,
			"atk": stats.atk,
			"multiplier": skill_3_atk_multiplier,
		}
	)
