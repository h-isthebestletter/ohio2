extends Scene
class_name Level2D

@export var player_scene: PackedScene
@export var player_spawn: Marker2D
@export var enemy_spawn_points: Array[Marker2D]
@export var enemy_scenes: Array[PackedScene]
@export var timeline: AnimationPlayer
@export var enemy_count: int

var player: Player2D

var enemy_spawners: Array[EnemySpawner] = []

class EnemySpawner:
	var enemy_id: int
	var at: int
	var spawner: Callable
	
	var count: int
	var duration: float
	var distance_offset: float
	
	var time: float
	var spawned: int
	
	func _init(enemy_id: int, at: int, spawner: Callable, count: int, duration: float, distance_offset: float) -> void:
		self.enemy_id = enemy_id
		self.at = at
		self.spawner = spawner
		
		self.count = count
		self.duration = duration
		self.distance_offset = distance_offset
		
		self.time = 0.0
		self.spawned = 0
	
	func update(delta: float) -> void:
		if spawned == count:
			return
		
		if duration == 0.0:
			while spawned < count:
				spawned += 1
				spawner.call(enemy_id, at, distance_offset)
			return
			
		time += delta
		var time_between_enemy_spawns := duration / float(count)
		while time_between_enemy_spawns * float(spawned + 1) <= time and spawned <= count:
			spawned += 1
			spawner.call(enemy_id, at, distance_offset)
			

func spawn_player() -> void:
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
	
func spawn_enemy(enemy_id: int, spawn_point_index: int, count: int = 1, duration: float = 0.0, distance_offset: float = 0.0) -> void:
	enemy_spawners.push_back(EnemySpawner.new(enemy_id, spawn_point_index, _actually_spawn_enemy, count, duration, distance_offset))

func _actually_spawn_enemy(enemy_id: int, spawn_point_index: int, distance: float) -> void:
	var offset := Vector2.from_angle(randf_range(0, TAU)) * randf_range(0.0, distance)
	
	var enemy: Enemy2D = enemy_scenes[enemy_id].instantiate()
	enemy.level = self
	enemy.player = player
	enemy.global_position = enemy_spawn_points[spawn_point_index].global_position + offset

	add_child(enemy)
	
	Signals.enemy_spawned.emit(enemy)

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

func _process(delta: float) -> void:
	for enemy_spawner in enemy_spawners:
		enemy_spawner.update(delta)

func _on_level_won() -> void:
	get_tree().paused = true

func _on_level_lost() -> void:
	get_tree().paused = true
