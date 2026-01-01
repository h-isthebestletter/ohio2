extends Enemy2D

var grenade_scene := preload("res://scenes/components/enemy_summons/grenade.tscn")

func _ready() -> void:
	super()
	# make Osama invincible while spawning
	receive_status_effect(StatusEffect.Kind.Invincible, 5.5)

func _process(delta: float) -> void:
	super(delta)
	# when Osama has less than 30% HP, become enraged
	if (
		float(health) / float(stats.max_health) < 0.4
		and not has_status_effect(StatusEffect.Kind.Enraged)
	):
		receive_status_effect(StatusEffect.Kind.Enraged, INF)

func update_state_machine() -> void:
	if (global_position - target_position).length() <= 1000.0:
		state = State.Attacking
	else:
		state = State.Moving

func attack() -> void:
	animation_player.play("attacking")
	create_summon(grenade_scene.instantiate(), {
		"from": global_position,
		"to": target_position,
		"speed": 1600.0,
		"atk": stats.atk,
		"attack_speed": stats.attack_speed
	})
