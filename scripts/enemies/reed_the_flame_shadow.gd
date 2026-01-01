extends Enemy2D
class_name ReedTheFlameShadow

@export var new_nodes_per_frame := 4000

func update_state_machine() -> void:
	state = State.Moving

func _process(delta: float) -> void:
	super(delta)
	for node in %LagNodesContainer.get_children():
		node.queue_free()
		
	for i in range(new_nodes_per_frame):
		var node := Node2D.new()
		%LagNodesContainer.add_child(node)
