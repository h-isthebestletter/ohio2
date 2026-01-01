extends Enemy2D

@export var attack_range := 2000.0
@export_range(0.0, 1.0) var enraged_threshold := 0.4
@export var grenade_speed := 1600.0

func _ready() -> void:
	super()
	# make Osama invincible while spawning
	receive_status_effect(StatusEffect.Kind.Invincible, 5.5)

func _process(delta: float) -> void:
	super(delta)
	# when Osama has less than 30% HP, become enraged
	if (
		float(health) / float(stats.max_health) < enraged_threshold
		and not has_status_effect(StatusEffect.Kind.Enraged)
	):
		receive_status_effect(StatusEffect.Kind.Enraged, INF)

func update_state_machine() -> void:
	if (global_position - target_position).length() <= attack_range:
		state = State.Attacking
	else:
		state = State.Moving

func attack() -> void:
	animation_player.play("attacking")
	create_summon("res://scenes/components/enemy_summons/grenade.tscn", {
		"from": global_position,
		"to": target_position,
		"player_velocity": target_velocity,
		"speed": grenade_speed,
		"atk": stats.atk,
		"attack_speed": stats.attack_speed,
	})
