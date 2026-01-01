extends Label

func _on_player_spawned(player_name: String, health: float, max_health: float, skill_points: int) -> void:
	text = "{sp} SP".format({ "sp": skill_points })

func _on_player_skill_point_changed(new_skill_point: int) -> void:
	text = "{sp} SP".format({ "sp": new_skill_point })

func _ready() -> void:
	Signals.player_spawned.connect(_on_player_spawned)
	Signals.player_skill_point_changed.connect(_on_player_skill_point_changed)
