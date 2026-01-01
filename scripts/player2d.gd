extends Entity2D
class_name Player2D

## Initial skill points.
@export var skill_points := 20:
	set(val):
		Signals.player_skill_point_changed.emit(val)
		skill_points = min(val, 99)

## How many seconds should pass before another skill point is given.
@export var skill_point_regenerate_interval := 0.5 # give one SP every 0.5s

@export var skills_sp_cost: Array[int] = [100, 100, 100]

enum State {
	ALIVE,
	DYING,
	DEAD
}

var state := State.ALIVE

var _last_time_skill_point_given := 0.0
var time := 0.0
var skills_duration: Array[float] = [0.0, 0.0, 0.0]

var attack_direction: float = 0.0

func _process(delta: float) -> void:
	super(delta)
	time += delta
	if health == 0 and state != State.DEAD:
		state = State.DYING
		animation_player.play("dying")
		animation_player.animation_finished.connect(func (_anim_name: StringName):
			# MUST NOT CALL queue_free() ON PLAYER!!
			state = State.DEAD
		)
	
	for i in range(len(skills_duration)):
		# tick remaining skill duration
		skills_duration[i] = max(0.0, skills_duration[i] - delta)
	
	var mouse_position = get_local_mouse_position()
	attack_direction = atan2(
		mouse_position.y, mouse_position.x
	)
	$PlayerDirectionSelect.rotation = attack_direction
	$Hitboxes.rotation = attack_direction
	
	if time - _last_time_skill_point_given> skill_point_regenerate_interval:
		_last_time_skill_point_given += skill_point_regenerate_interval
		skill_points += 1

func _physics_process(delta: float) -> void:
	if state != State.ALIVE: return
	var input_direction := Input.get_vector(
		"player_move_left", "player_move_right",
		"player_move_up", "player_move_down"
	)
	velocity = input_direction * stats.movement_speed
	move_and_slide()
	Signals.player_moved.emit(global_position, velocity)

func _input(event: InputEvent) -> void:
	if state != State.ALIVE: return
	if Input.is_action_just_pressed("player_attack"):
		if not has_status_effect(StatusEffect.Kind.Stunned):
			attack()
	
	if Input.is_action_just_pressed("player_use_skill_1"):
		if not is_skill_active(1) and can_afford_skill(1):
			if not has_status_effect(StatusEffect.Kind.Stunned):
				skill_points -= skills_sp_cost[0]
				use_skill_1()
		
	if Input.is_action_just_pressed("player_use_skill_2"):
		if not is_skill_active(2) and can_afford_skill(2):
			if not has_status_effect(StatusEffect.Kind.Stunned):
				skill_points -= skills_sp_cost[1]
				use_skill_2()
	
	if Input.is_action_just_pressed("player_use_skill_3"):
		if not is_skill_active(3) and can_afford_skill(3):
			if not has_status_effect(StatusEffect.Kind.Stunned):
				skill_points -= skills_sp_cost[2]
				use_skill_3()

func use_skill_1() -> void:
	pass

func use_skill_2() -> void:
	pass

func use_skill_3() -> void:
	pass

## [code]skill[/code] takes in 1, 2, 3 as parameters, not 0, 1, 2.
func set_skill_duration(skill: int, remaining_duration: float) -> void:
	skills_duration[skill - 1] = remaining_duration

func is_skill_active(skill: int) -> bool:
	return skills_duration[skill - 1] > 0.0

func can_afford_skill(skill: int) -> bool:
	return skill_points >= skills_sp_cost[skill - 1]
