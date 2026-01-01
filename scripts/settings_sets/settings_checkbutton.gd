extends SettingsSet

func _ready() -> void:
	%Label.text = key.capitalize()
	%CheckButton.button_pressed = value
	%CheckButton.pressed.connect(_on_pressed)

func _on_pressed() -> void:
	change_value(not value)
