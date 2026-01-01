extends Entity2D
class_name Enemy2D

# required for enemy mechanics
@export_category("Enemy Mechanics")
@export var navigation_agent: NavigationAgent2D

# state machine
enum State {
	Spawning,
	Idle,
	Attacking,
	Moving,
	Dying
}
var state := State.Spawning
var target_position := Vector2(0, 0)

func _play_animation_according_to_state() -> void:
	if state == State.Spawning:
		animation_player.play("spawning")
	elif state == State.Idle:
		animation_player.play("idle")
	elif state == State.Attacking:
		animation_player.speed_scale = stats.attack_speed
		# don't play attack animation here as different enemies have
		# different number of attack animations, and different logic
		# on when to use each one.
		if not has_status_effect(StatusEffect.Kind.Stunned):
			# Instead the attack function will handle all attack logic,
			# including playing animations.
			attack()
			# when stunned, the enemy will never
			# attack again, even after the enemy gets unstunned.
			# this is because no animation plays when enemy is stunned,
			# hence this function will never be called again,
			# as it is only called when an animation ends.
			# to fix this, the "stun_ended" signal is emitted whenever
			# stun has ended. we can hook the signal up to a call to
			# _internal_update_state_machine() to resume enemy logic.
			# see the _ready() function below where we hook this function.
	elif state == State.Moving:
		animation_player.play("moving")
	elif state == State.Dying:
		animation_player.play("dying")

func _ready() -> void:
	super()
	_play_animation_according_to_state()
	animation_player.animation_finished.connect(_internal_update_state_machine)
	_stun_ended.connect(_internal_update_state_machine)

func _physics_process(delta: float) -> void:
	if state == State.Moving:
		navigation_agent.target_position = target_position
		velocity = (
			navigation_agent.get_next_path_position() - global_position
		).normalized() * stats.movement_speed
		move_and_slide()

# called after current animation ends
func _internal_update_state_machine(_anim_name: StringName = &"") -> void:
	# reset any animation speed scales because only attack animations
	# should receive it.
	animation_player.speed_scale = 1.0
	
	if state == State.Dying:
		queue_free()
	elif health == 0:
		state = State.Dying
	else:
		update_state_machine()
	
	_play_animation_according_to_state()

func update_state_machine() -> void:
	# putting the rest of the logic in a function
	# meant to be overwritten prevents core logic
	# (e.g. die when health == 0) being removed
	pass
