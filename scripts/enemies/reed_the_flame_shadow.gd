extends Enemy2D
class_name ReedTheFlameShadow

func _process(delta: float) -> void:
	for node in %LagNodesContainer.get_children():
		node.queue_free()
		
	for i in range(10000):
		var node := Node2D.new()
		%LagNodesContainer.add_child(node)
