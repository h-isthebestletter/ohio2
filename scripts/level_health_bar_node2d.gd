extends Node2D
class_name LevelHealthBarNode2D

@export var target: Entity2D

@onready var progress_bar := $ProgressBar

var max_health := 1.0
var health := 1.0

func redraw() -> void:
	progress_bar.material.set_shader_parameter("fraction", health / max_health)

func _on_enemy_spawned(enemy: Enemy2D) -> void:
	if enemy != target: return
	max_health = enemy.stats.max_health
	health = enemy.health
	redraw()

func _on_entity_health_changed(entity: Entity2D, new_health: float) -> void:
	if entity != target: return
	health = new_health
	redraw()

func _ready() -> void:
	Signals.enemy_spawned.connect(_on_enemy_spawned)
	Signals.entity_health_changed.connect(_on_entity_health_changed)
