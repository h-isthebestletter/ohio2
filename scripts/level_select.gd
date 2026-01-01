extends Scene

@onready var map := %Map
@onready var level_details := %LevelDetails

var level_id: int

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
