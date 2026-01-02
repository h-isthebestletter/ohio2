extends TextureButton
class_name LevelSelectLevelButton

@export var level_id: int
@onready var level_data: Array = load("res://resources/level_data.json").data
@onready var completion_data = GameSaver.game_save.level_completion

signal level_selected(level_id: int)

func _ready() -> void:
	if level_id == 0 or completion_data[level_id - 1] == true:
		show()
	else:
		hide()
	
	$Label.text = level_data[level_id].label

func _pressed() -> void:
	emit_signal("level_selected", level_id)
