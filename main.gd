extends Control

var current_scene: Node
var current_level_id
var _next_scene_resporce_path := ""
var _next_cutscene_target_level_id := -1

@onready var dialogue_data: Dictionary = preload("res://resources/dialogue.json").data

func _ready() -> void:
	Signals.request_change_scene.connect(replace_scene_with_animation)
	Signals.request_change_bgm.connect(replace_bgm)
	Signals.request_load_cutscene.connect(_on_request_load_cutscene)
	Signals.request_load_level.connect(_on_request_load_level)
	Signals.level_won.connect(_on_level_won)
	
	replace_scene("res://scenes/title.tscn")

func replace_scene_with_animation(new_scene_resource_path: String) -> void:
	if _next_scene_resporce_path != "": return
	_next_scene_resporce_path = new_scene_resource_path
	%AnimationPlayer.play(&"fade_in")

func replace_scene(new_scene_resource_path: String) -> void:
	if get_child_count() > 4:
		current_scene.get_tree().paused = false
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = load(new_scene_resource_path).instantiate() as Scene
	if _next_cutscene_target_level_id != -1:
		(current_scene as CutsceneBase).story_id = _next_cutscene_target_level_id
	_next_cutscene_target_level_id = -1
	Signals.request_change_bgm.emit(current_scene.get_correct_bgm_stream())
	add_child(current_scene)

func replace_scene_with_next() -> void:
	replace_scene(_next_scene_resporce_path)
	_next_scene_resporce_path = ""
	%AnimationPlayer.play(&"fade_out")

func replace_bgm(new_bgm: AudioStream) -> void:
	var new_bgm_resource_path = new_bgm.resource_path if new_bgm else null
	var current_bgm_resource_path = (
		%AudioStreamPlayer.stream.get(&"resource_path")
		if %AudioStreamPlayer.get(&"stream") else null
	)
	
	if new_bgm_resource_path != current_bgm_resource_path:
		%AudioStreamPlayer.stop()

		if new_bgm != null:
			%AudioStreamPlayer.stream = new_bgm
			
		%AudioStreamPlayer.play()

func _on_request_load_cutscene(cutscene_id: int) -> void:
	if dialogue_data.get(str(cutscene_id)) != null:
		_next_cutscene_target_level_id = cutscene_id
		replace_scene_with_animation("res://scenes/cutscene_base.tscn")
	else:
		# load level directly if level doesn't come with a cutscene
		_on_request_load_level(cutscene_id)

func _on_request_load_level(level_id: int) -> void:
	current_level_id = level_id
	var path = "res://scenes/levels/{id}.tscn".format({
		"id": level_id
	})
	if FileAccess.file_exists(path):
		replace_scene_with_animation(path)
	else:
		# count stage as completed since there's no level
		_on_level_won()
		# load level select screen directly if cutscene doesn't come with a level
		replace_scene_with_animation("res://scenes/level_select.tscn")

func _on_level_won() -> void:
	if current_level_id != null:
		GameSaver.mark_level_as_completed(current_level_id)
		current_level_id = null
