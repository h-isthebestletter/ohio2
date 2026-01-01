extends CharacterBody2D
class_name Car

@export var speed := 3600.0
@export var atk := 2000.0
@export var path: Path2D
## If the player is continuously getting hit by the car, this value is the number of seconds between each instance of damage.
@export var player_collision_cooldown := 0.5

var path_follow: PathFollow2D

var time_since_last_collision := 0.0

func _ready() -> void:
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	global_position = path_follow.global_position

func _physics_process(delta: float) -> void:
	time_since_last_collision += delta
	
	velocity = Vector2.from_angle(path_follow.rotation) * speed
	path_follow.progress += speed * delta
	
	if time_since_last_collision > player_collision_cooldown:
		for body in $Area2D.get_overlapping_bodies():
			if body is Player2D:
				time_since_last_collision = 0.0
				body.take_damage(atk)
	
	move_and_slide()
