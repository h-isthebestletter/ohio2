extends Scene

func _ready() -> void:
	super()
	
	%LevelSelect.connect("pressed", func ():
		Signals.request_change_scene.emit("res://scenes/level_select.tscn")
	)
	
	%Settings.connect("pressed", func ():
		Signals.request_change_scene.emit("res://scenes/settings.tscn")
	)
