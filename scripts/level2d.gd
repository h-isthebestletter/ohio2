extends Scene
class_name Level2D

@export var player_scene: PackedScene
@export var player_initial_position: Vector2
@export var enemy_scenes: Array[PackedScene]
@export var timeline: AnimationPlayer
@export var enemy_count: int

var player: Player2D

func spawn_player() -> Player2D:
	player = player_scene.instantiate()
	add_child(player)
	player.global_position = player_initial_position
	
	Signals.player_spawned.emit(
		player.character_name,
		player.stats.max_health,
		player.health,
		player.skill_points,
	)
	
	return player

func spawn_enemy(enemy_id: int, at: Vector2) -> Enemy2D:
	var enemy: Enemy2D = enemy_scenes[enemy_id].instantiate()
	add_child(enemy)
	enemy.global_position = at
	
	Signals.enemy_spawned.emit(enemy)
	
	return enemy

func get_all_enemies() -> Array[Enemy2D]:
	return get_children().filter(func (x): return x is Enemy2D)

func get_all_player_summons() -> Array[PlayerSummon2D]:
	return get_children().filter(func (x): return x is PlayerSummon2D)

func get_all_enemy_summons() -> Array[EnemySummon2D]:
	return get_children().filter(func (x): return x is EnemySummon2D)

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
