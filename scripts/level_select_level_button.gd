extends TextureButton
class_name LevelSelectLevelButton

@export var level_id: int
@onready var level_data: Array = load("res://resources/level_data.json").data
@onready var completion_data = GameSaver.game_save.level_completion

signal level_selected(level_id: int)

var is_dragging := false

func _ready() -> void:
	if level_id == 0 or completion_data[level_id - 1] == true:
		show()
	else:
		hide()
	
	$Label.text = level_data[level_id].label

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not event.relative.is_zero_approx():
			is_dragging = true
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
		if not is_dragging and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("level_selected", level_id)
