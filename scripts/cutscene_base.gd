extends Scene
class_name CutsceneBase

@export var story_id := 0
@onready var data: Array = load("res://resources/dialogue.json").data[story_id]
@onready var dialogue_characters: Dictionary = load("res://resources/dialogue_characters.json").data

var character_idx := 0
var line_idx := 0
var active_slot := 1
var slots := [null, null]

var finished := false
var next_scene_requested := false

func load_image_onto_slot(file_path) -> void:
	if file_path == null: return
	if file_path in slots: return
	var image := Image.load_from_file(file_path)
	if active_slot == 1:
		slots[0] = file_path
		%Person1Image.texture = ImageTexture.create_from_image(image)
		active_slot = 2
		%Slot1.visible = true
	else:
		slots[1] = file_path
		%Person2Image.texture = ImageTexture.create_from_image(image)
		active_slot = 1
		%Slot2.visible = true

func overwrite_dialogue(name: String, dialogue: String) -> void:
	%PersonName.text = name
	%Dialogue.text = dialogue

func advance_dialogue() -> bool:
	load_image_onto_slot(dialogue_characters.get(data[character_idx]["speaker"]))
	overwrite_dialogue(data[character_idx]["speaker"], data[character_idx]["lines"][line_idx])
	
	line_idx += 1
	if line_idx == len(data[character_idx]["lines"]):
		line_idx = 0
		character_idx += 1
		if character_idx == len(data):
			return true
	
	return false

func _ready() -> void:
	super()
	# load first thing
	%SkipDialogueButton.pressed.connect(func ():
		Signals.request_load_level.emit(story_id)
		next_scene_requested = true
	)
	finished = advance_dialogue()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if not finished:
			finished = advance_dialogue()
		elif not next_scene_requested:
			Signals.request_load_level.emit(story_id)
			next_scene_requested = true
