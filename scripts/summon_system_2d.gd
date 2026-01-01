extends Node2D
class_name SummonSystem2D

class Pool:
	var packed_scene: PackedScene
	var unused: Array[Summon2D]
	var parent: Node
	
	func _init(_parent: Node, _packed_scene: PackedScene, count: int) -> void:
		parent = _parent
		packed_scene = _packed_scene
		unused = []
		
		for i in range(count):
			var new_summon: Summon2D = packed_scene.instantiate()
			
			new_summon.request_become_unused.connect(add_to_pool)
			parent.add_child(new_summon)
			add_to_pool(new_summon)
	
	func get_new_node(args: Dictionary[String, Variant]) -> Summon2D:
		var new_summon: Summon2D
		if unused.is_empty():
			new_summon = packed_scene.instantiate()
			new_summon.request_become_unused.connect(add_to_pool)
			parent.add_child(new_summon)
		else:
			new_summon = unused.pop_back()
		
		new_summon.initialize(args)
		
		new_summon.show()
		new_summon.set_process(true)
		new_summon.set_physics_process(true)
		
		return new_summon
	
	func add_to_pool(summon: Summon2D) -> void:
		summon.hide()
		summon.set_process(false)
		summon.set_physics_process(false)

		unused.push_back(summon)


@export var initial_object_count: Dictionary[String, int] = {}
@export var level: Level2D
var pools: Dictionary[String, Pool] = {}

func _ready() -> void:
	for packed_scene in initial_object_count:
		pools[packed_scene] = Pool.new(
			self,
			load(packed_scene),
			initial_object_count[packed_scene]
		)
	
	Signals.entity_request_create_summon.connect(new_summon)
	
func new_summon(
	summon_packed_scene_path: String,
	args: Dictionary[String, Variant]
) -> Summon2D:
	var pool = pools[summon_packed_scene_path]
	var summon = pool.get_new_node(args)
	return summon

func get_all_player_summons() -> Array:
	return get_children().filter(func (x): return x is PlayerSummon2D)

func get_all_enemy_summons() -> Array:
	return get_children().filter(func (x): return x is EnemySummon2D)
