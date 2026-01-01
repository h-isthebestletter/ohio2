extends Scene
class_name Level2D

@export var player_scene: PackedScene
@export var player_spawn: Marker2D
@export var enemy_spawn_points: Array[Marker2D]
@export var enemy_scenes: Array[PackedScene]
@export var paths: Array[Path2D]
@export var timeline: AnimationPlayer
@export var enemy_count: int

var player: Player2D

func spawn_player() -> Player2D:
	player = player_scene.instantiate()
	player.level = self
	player.global_position = player_spawn.global_position
	
	add_child(player)
	
	Signals.player_spawned.emit(
		player.character_name,
		player.stats.max_health,
		player.health,
		player.skill_points,
	)
	
	return player

func spawn_enemy(enemy_id: int, spawn_point_index: int) -> Enemy2D:
	var enemy: Enemy2D = enemy_scenes[enemy_id].instantiate()
	enemy.level = self
	enemy.player = player
	enemy.paths = paths
	enemy.global_position = enemy_spawn_points[spawn_point_index].global_position

	add_child(enemy)
	
	Signals.enemy_spawned.emit(enemy)
	
	return enemy

func get_all_enemies() -> Array:
	return get_children().filter(func (x): return x is Enemy2D)

func get_all_player_summons() -> Array:
	return $SummonSystem2D.get_all_player_summons()

func get_all_enemy_summons() -> Array:
	return $SummonSystem2D.get_all_enemy_summons()

func _ready() -> void:
	super()
	Signals.level_loaded.emit(
		enemy_count
	)
	Signals.level_won.connect(_on_level_won)
	Signals.level_lost.connect(_on_level_lost)
	# player has to outlive enemy, spawn player first
	spawn_player()

func _on_level_won() -> void:
	get_tree().paused = true

func _on_level_lost() -> void:
	get_tree().paused = true
