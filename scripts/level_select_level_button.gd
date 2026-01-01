extends TextureButton
class_name LevelSelectLevelButton

@export var level_id: int
@onready var level_data: Array = load("res://resources/level_data.json").data
@onready var completion_data = GameSaver.game_save.level_completion

signal level_selected(level_id: int)

func get_last_completed_level_id() -> int:
	var last_completed_level_id := -1
	while last_completed_level_id < len(completion_data):
		if not completion_data[last_completed_level_id + 1]:
			return last_completed_level_id
		last_completed_level_id += 1
		
	return last_completed_level_id

func _ready() -> void:
	if level_id > get_last_completed_level_id() + 1:
		hide()
	
	$Label.text = level_data[level_id].label

func _pressed() -> void:
	emit_signal("level_selected", level_id)
