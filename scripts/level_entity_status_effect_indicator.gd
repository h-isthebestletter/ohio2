extends Node2D

@export var target: Entity2D

func _ready() -> void:
	Signals.entity_status_effects_changed.connect(_on_status_effect_changed)

func _on_status_effect_changed(entity: Entity2D, status_effects: Array[float]) -> void:
	if entity != target: return
	%Enraged.visible = status_effects[StatusEffect.Kind.Enraged] != 0.0
	%Regenerating.visible = status_effects[StatusEffect.Kind.Regenerating] != 0.0
	%Slowed.visible = status_effects[StatusEffect.Kind.Slowed] != 0.0
	%Invincible.visible = status_effects[StatusEffect.Kind.Invincible] != 0.0
	%Frozen.visible = status_effects[StatusEffect.Kind.Frozen] != 0.0
	%Tenacious.visible = status_effects[StatusEffect.Kind.Tenacious] != 0.0
	%Poisoned.visible = status_effects[StatusEffect.Kind.Poisoned] != 0.0
	%Stunned.visible = status_effects[StatusEffect.Kind.Stunned] != 0.0
