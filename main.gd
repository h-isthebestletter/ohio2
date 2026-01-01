extends Control

var current_scene: Node
var _next_scene: Node

func _ready() -> void:
	Signals.request_change_scene.connect(replace_scene_with_animation)
	Signals.request_change_bgm.connect(replace_bgm)
	Signals.request_load_cutscene.connect(_on_request_load_cutscene)
	Signals.request_load_level.connect(_on_request_load_level)
	
	replace_scene(preload("res://scenes/title.tscn").instantiate())

func replace_scene(new_scene: Scene) -> void:
	if get_child_count() > 3:
		current_scene.get_tree().paused = false
		remove_child(current_scene)
		current_scene.queue_free()
	
	current_scene = new_scene
	Signals.request_change_bgm.emit(current_scene.bgm)
	add_child(current_scene)

func replace_scene_with_next() -> void:
	replace_scene(_next_scene)
	_next_scene = null
	%AnimationPlayer.play(&"fade_out")

func replace_scene_with_animation(new_scene: Scene) -> void:
	if _next_scene != null: return
	_next_scene = new_scene
	%AnimationPlayer.play(&"fade_in")

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
	var scene: CutsceneBase = preload("res://scenes/cutscene_base.tscn").instantiate()
	scene.story_id = cutscene_id
	replace_scene_with_animation(scene)

func _on_request_load_level(level_id: int) -> void:
	var path = "res://scenes/levels/{id}.tscn".format({
		"id": level_id
	})
	replace_scene_with_animation(load(path).instantiate())
	
