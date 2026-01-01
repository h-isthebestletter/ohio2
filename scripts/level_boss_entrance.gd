extends Polygon2D
class_name BossEntrance

var animation_started = false
var time := 0.0

func start_animation() -> void:
	animation_started = true

func _process(delta: float) -> void:
	if not animation_started: return
	material.set_shader_parameter("ADJUSTED_TIME", time)
	time += delta
