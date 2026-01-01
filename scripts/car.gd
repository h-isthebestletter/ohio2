extends CharacterBody2D
class_name Car

@export var sprite: Sprite2D
@export var speed := 3600.0
@export var atk := 2000.0
@export var path: Path2D
## If the player is continuously getting hit by the car, this value is the number of seconds between each instance of damage.
@export var player_collision_cooldown := 0.5

var path_follow: PathFollow2D

var old_global_position := Vector2(INF, INF)

var time_since_last_collision := 0.0

func _ready() -> void:
	path_follow = PathFollow2D.new()
	path.add_child(path_follow)
	global_position = path_follow.global_position

func _process(delta: float) -> void:
	if (global_position - old_global_position).x < 0.0:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	time_since_last_collision += delta
	
	old_global_position = global_position
	
	path_follow.progress += speed * delta
	global_position = path_follow.global_position
	
	if time_since_last_collision > player_collision_cooldown:
		for body in $Area2D.get_overlapping_bodies():
			if body is Player2D:
				time_since_last_collision = 0.0
				body.take_damage(atk)
	
	move_and_slide()
