extends InsignificantEnemy2D

@export var path_to_follow := 0
## If the player is continuously getting hit by the car, this value is the number of seconds between each instance of damage.
@export var player_collision_cooldown := 0.5

var path: Path2D
var path_follow: PathFollow2D

var time_since_last_collision := 0.0

func _ready() -> void:
	super()
	path = paths[path_to_follow]
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	global_position = path_follow.global_position

func _physics_process(delta: float) -> void:
	time_since_last_collision += delta
	if state == State.Moving:
		velocity = Vector2.from_angle(path_follow.rotation) * stats.movement_speed
		path_follow.progress += stats.movement_speed * delta
	
	if time_since_last_collision > player_collision_cooldown:
		for body in $Area2D.get_overlapping_bodies():
			if body is Player2D:
				time_since_last_collision = 0.0
				body.take_damage(stats.atk)
	
	move_and_slide()

func update_state_machine() -> void:
	# putting the rest of the logic in a function
	# meant to be overwritten prevents core logic
	# (e.g. die when health == 0) being removed
	state = State.Moving
