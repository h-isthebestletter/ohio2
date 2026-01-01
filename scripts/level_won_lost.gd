extends Control

var timeout := 4.0
var level_select := preload("res://scenes/level_select.tscn")

signal confirmed

func won_lost(won: bool) -> void:
	visible = true
	if won:
		%LevelWon.visible = true
		%LevelWonAudio.play()
	else:
		%LevelLost.visible = true
		%LevelLostAudio.play()
		
	await confirmed
	Signals.request_change_scene.emit(level_select.instantiate())

func _ready() -> void:
	Signals.level_won.connect(won_lost.bind(true))
	Signals.level_lost.connect(won_lost.bind(false))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		confirmed.emit()
