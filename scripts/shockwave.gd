extends Polygon2D
class_name Shockwave

var animation_playing = false
var time := 0.0

func start_animation() -> void:
	visible = true
	animation_playing = true

func pause_animation() -> void:
	animation_playing = false

func reset() -> void:
	visible = false
	time = 0.0

func stop_animation() -> void:
	pause_animation()
	reset()

func _process(delta: float) -> void:
	if not animation_playing: return
	material.set_shader_parameter("ADJUSTED_TIME", time)
	time += delta
	if time > 1.0:
		stop_animation()
