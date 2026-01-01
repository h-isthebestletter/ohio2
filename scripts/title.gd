extends Scene

func _ready() -> void:
	%LevelSelect.connect("pressed", func ():
		Signals.request_change_scene.emit(load("res://scenes/level_select.tscn").instantiate())
	)
	
	%Settings.connect("pressed", func ():
		# Signals.request_change_scene.emit(load("res://scenes/settings.tscn").instantiate())
		pass
	)
