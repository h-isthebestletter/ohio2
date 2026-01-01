extends Node

# GENERAL ENTITY
signal entity_request_create_summon(
	summon_scene: Summon2D,
	args: Dictionary[String, Variant],
)
signal entity_health_changed(
	entity: Entity2D,
	new_health: float,
)
signal entity_status_effects_changed(
	entity: Entity2D,
	new_status_effects: Array[float],
)
signal entity_died(
	entity: Entity2D,
)

# PLAYER
signal player_spawned(
	player_name: String,
	max_health: float,
	health: float,
	skill_points: int,
)
signal player_moved(
	new_position: Vector2,
)
signal player_skill_point_changed(
	new_skill_point: int,
)

# ENEMY
signal enemy_spawned(
	enemy: Enemy2D,
)

# LEVEL
signal level_won(
	
)
signal level_lost(
	
)

# SCENE
signal request_change_scene(
	new_scene: Node,
)
signal request_load_cutscene(
	cutscene_id: int,
)
signal request_load_level(
	level_id: int,
)
signal request_change_bgm(
	new_bgm: AudioStream,
)
