extends Control

var current_scene: Node
var _next_scene: Node

func _ready() -> void:
	Signals.request_change_scene.connect(replace_scene_with_animation)
	Signals.request_change_bgm.connect(replace_bgm)
	Signals.request_load_cutscene.connect(_on_request_load_cutscene)
	Signals.request_load_level.connect(_on_request_load_level)
	
	replace_scene(preload("res://scenes/title.tscn").instantiate())

func replace_scene(new_scene: Node) -> void:
	if get_child_count() > 3:
		remove_child(current_scene)
		current_scene.queue_free()
		
	current_scene = new_scene
	add_child(current_scene)

func replace_scene_with_animation(new_scene: Node) -> void:
	if _next_scene != null: return
	_next_scene = new_scene
	%AnimationPlayer.play(&"fade")

func replace_scene_with_next() -> void:
	replace_scene(_next_scene)
	_next_scene = null

func replace_bgm(new_bgm: AudioStream) -> void:
	%AudioStreamPlayer.stop()
	%AudioStreamPlayer.stream = new_bgm
	%AudioStreamPlayer.play()

func _on_request_load_cutscene(cutscene_id: int) -> void:
	var path = "res://scenes/cutscene_base.tscn"
	var scene: CutsceneBase = load(path).instantiate()
	scene.story_id = cutscene_id
	replace_scene_with_animation(scene)

func _on_request_load_level(level_id: int) -> void:
	var path = "res://scenes/levels/{id}.tscn".format({
		"id": level_id
	})
	replace_scene_with_animation(load(path).instantiate())
	
