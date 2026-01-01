extends Node
class_name Scene

@export var bgm: AudioStream
@export var chinese_bgm: AudioStream

var using_chinese_bgm: bool = GameSaver.game_save.settings["chinese_music"].value

func _on_use_chinese_bgm(chinese: bool) -> void:
	using_chinese_bgm = chinese
	if not using_chinese_bgm:
		Signals.request_change_bgm.emit(bgm)
	else:
		Signals.request_change_bgm.emit(chinese_bgm)

func get_correct_bgm_stream() -> AudioStream:
	if not using_chinese_bgm:
		return bgm
	else:
		return chinese_bgm

func _ready() -> void:
	Signals.use_chinese_bgm.connect(_on_use_chinese_bgm)
