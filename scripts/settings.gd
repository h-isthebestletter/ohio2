extends Scene

var data = GameSaver.game_save

@onready var check_button_scene := preload("res://scenes/components/settings_sets/settings_checkbox.tscn")

func _ready() -> void:
	super()
	for key: String in data.settings.keys():
		var setting: Dictionary = data.settings[key]
		match setting.type:
			GameSave.SettingType.CheckButton:
				var check_button: SettingsSet = check_button_scene.instantiate()
				check_button.key = key
				check_button.value = setting.value
				%VBoxContainer.add_child(check_button)
