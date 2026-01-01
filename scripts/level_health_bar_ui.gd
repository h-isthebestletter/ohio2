extends Control
class_name HealthBarUI

@onready var progress_bar := $ProgressBar
@onready var label := $Label

var max_health := 1.0
var health := 1.0
var target_name := ""

func redraw() -> void:
	# scene is not set up, don't attempt redraw
	# if progress_bar == null or label == null: return
	progress_bar.max_value = max_health
	progress_bar.value = health
	
	label.text = "{target_name} HP: {current}/{maximum} ({percentage}%)".format(
		{
			"target_name": target_name,
			"current": "%.2f" % health,
			"maximum": progress_bar.max_value,
			"percentage": "%.2f" % ((health / progress_bar.max_value) * 100)
		}
	)

func _on_player_spawned(
	player_name: String,
	player_max_health: float,
	player_health: float,
	player_skill_points: int
) -> void:
	target_name = player_name
	max_health = player_max_health
	health = player_health
	redraw()

func _on_entity_health_changed(entity: Entity2D, new_health: float) -> void:
	if entity is not Player2D: return
	health = new_health
	redraw()

func _ready() -> void:
	Signals.player_spawned.connect(_on_player_spawned)
	Signals.entity_health_changed.connect(_on_entity_health_changed)
