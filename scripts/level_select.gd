extends Scene

@onready var map := %Map
@onready var level_details := %LevelDetails

var level_id: int
var is_dragging := false

func _ready() -> void:
	super()
	var level_buttons = map.get_children()
	for button in level_buttons:
		if button is LevelSelectLevelButton:
			button.level_selected.connect(func (selected_level_id: int):
				level_details.set_level(selected_level_id)
				level_details.open()
				level_id = selected_level_id
			)
	
	%Play.pressed.connect(func ():
		Signals.request_load_cutscene.emit(level_id)
	)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not event.relative.is_zero_approx():
			is_dragging = true
	elif event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
		if not is_dragging and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
			level_details.close()
