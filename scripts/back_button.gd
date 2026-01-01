extends Button
class_name BackButton

## Scene to change to when the back button is pressed.
@export var scene_path: String

func _pressed() -> void:
	Signals.request_change_scene.emit(scene_path)
