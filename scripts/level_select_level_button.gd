extends TextureButton
class_name LevelSelectLevelButton

@export var level_id: int
@onready var level_data: Array = load("res://resources/level_data.json").data

signal level_selected(level_id: int)

func _ready() -> void:
	$Label.text = level_data[level_id].label

func _pressed() -> void:
	emit_signal("level_selected", level_id)
