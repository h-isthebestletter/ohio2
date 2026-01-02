extends Resource
class_name GameSave

enum SettingType {
	CheckButton,
}

class Setting:
	var type: SettingType
	var value: Variant
	
	func _init(type: SettingType, value: Variant) -> void:
		self.type = type
		self.value = value

@export var settings: Dictionary[String, Dictionary] = {
	"chinese_music": {
		"type": SettingType.CheckButton,
		"value": false
	},
}

@export var level_completion: Array[bool] = [
	# allocate enough space for 30 levels
	# mark challenge mode stages as completed as they were not intended to be
	# possible to beat
	false, false, false, false, false, false, false, false, false, false,
	false, false, false, false, false, false, false, false, false, false,
	true , true , true , true , true , false, false, false, false, false,
]
