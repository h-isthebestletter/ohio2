extends PanelContainer

@onready var original_position := position
@onready var level_data: Array = load("res://resources/level_data.json").data
var is_open := false

func open() -> void:
	if is_open:
		return
	is_open = true
	var open_tween := get_tree().create_tween()
	open_tween.tween_callback(show)
	open_tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func close() -> void:
	if not is_open:
		return
	is_open = false
	var close_tween := get_tree().create_tween()
	close_tween.tween_property(self, "position", original_position + Vector2(size.x, 0), 0.2)
	close_tween.tween_callback(hide)

func set_level(level_id: int) -> void:
	%Title.text = level_data[level_id].name
	%Description.text = level_data[level_id].description

func _ready() -> void:
	# initialize to closed state
	position = original_position + Vector2(size.x, 0)
	hide()
