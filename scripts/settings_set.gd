extends HBoxContainer
class_name SettingsSet

var key: String
var value: Variant

func _ready() -> void:
	pass

func change_value(new_value: Variant) -> void:
	value = new_value
	Signals.settings_key_updated.emit(key, value)
