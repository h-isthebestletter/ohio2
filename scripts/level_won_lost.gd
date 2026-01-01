extends Control

var timeout := 4.0

signal confirmed

func won_lost(won: bool) -> void:
	visible = true
	if won:
		%LevelWon.visible = true
		Signals.request_change_bgm.emit(
			Utils.load_looping_mp3("res://assets/audio/sound_effects/ohmygod.mp3")
		)
	else:
		%LevelLost.visible = true
		Signals.request_change_bgm.emit(
			Utils.load_looping_mp3("res://assets/audio/sound_effects/fnaf2.mp3")
		)
		
	await confirmed
	Signals.request_change_scene.emit("res://scenes/level_select.tscn")

func _ready() -> void:
	Signals.level_won.connect(won_lost.bind(true))
	Signals.level_lost.connect(won_lost.bind(false))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		confirmed.emit()
