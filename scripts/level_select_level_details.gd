extends PanelContainer

@onready var original_position := position
@onready var level_data: Array = load("res://resources/level_data.json").data
var is_open := false

func open() -> void:
	if is_open:
		return
	is_open = true
	$AnimationPlayer.play(&"open")

func close() -> void:
	if not is_open:
		return
	is_open = false
	$AnimationPlayer.play(&"close")

func set_level(level_id: int) -> void:
	%Title.text = level_data[level_id].name
	%Description.text = level_data[level_id].description
