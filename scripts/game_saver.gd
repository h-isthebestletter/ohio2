extends Node

const SAVE_PATH := "user://game_save.tres"

var game_save: GameSave = null

func _ready() -> void:
	Signals.settings_key_updated.connect(_on_settings_key_updated)
	if ResourceLoader.exists(SAVE_PATH):
		game_save = ResourceLoader.load(SAVE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	else:
		game_save = GameSave.new()
		save()

func _on_settings_key_updated(key: String, new_value: Variant) -> void:
	game_save.settings[key].value = new_value
	if key == "chinese_music":
		Signals.use_chinese_bgm.emit(new_value)
	save()

func mark_level_as_completed(level_id: int) -> void:
	game_save.level_completion[level_id] = true
	save()

func save() -> void:
	var error := ResourceSaver.save(game_save, SAVE_PATH)
	if error != OK:
		push_error("Failed to save game: " + error_string(error))
	#else:
		#print("Game saved.")
	
