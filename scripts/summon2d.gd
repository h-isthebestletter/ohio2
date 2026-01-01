extends Sprite2D
class_name Summon2D

var args: Dictionary[String, Variant]

signal request_become_unused(object: Summon2D)

# meant for SummonSystem2D (object pool)
func initialize(args: Dictionary[String, Variant]) -> void:
	pass
