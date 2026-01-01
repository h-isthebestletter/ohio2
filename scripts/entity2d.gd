extends CharacterBody2D
class_name Entity2D

class Stats:
	var max_health: float
	var atk: float
	var def: float
	var attack_speed: float
	var movement_speed: float
	
	func _has_status_effect(status_effects: Array[float], kind: StatusEffect.Kind) -> bool:
		return status_effects[kind] > 0.0
	
	func _init(max_health: float, atk: float, def: float, attack_speed: float, movement_speed: float) -> void:
		self.max_health = max_health
		self.atk = atk
		self.def = def
		self.attack_speed = attack_speed
		self.movement_speed = movement_speed

@export_category("Stats")
@export var _max_health := 10000.0
@export var _atk := 2700.0
## Flat amount subtracted from every attack received.
@export var _def := 600.0
## Implemented as an attack animation speed multiplier.
@export var _attack_speed := 1.0
## Movement speed in pixels per second.
@export var _movement_speed := 800.0

@export_category("Mechanics")
@export var animation_player: AnimationPlayer
@export var sprite: Sprite2D

@onready var base_stats := Stats.new(_max_health, _atk, _def, _attack_speed, _movement_speed)
@onready var stats = base_stats

# signal meant for internal use
signal _stun_ended

@onready var health := _max_health:
	set(val):
		var old_health = health
		if val < 0:
			health = 0
			_emit_signal_died()
		else:
			health = min(stats.max_health, val)
			
		if health != old_health:
			_emit_signal_health_changed(health)

# each number corresponds to the duration of that status effect left
var status_effects: Array[float] = [
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
]

var sprite_facing_right := true

func _ready() -> void:
	health = stats.max_health

func _process(delta: float) -> void:
	var was_stunned := has_status_effect(StatusEffect.Kind.Stunned)
	for i in range(len(status_effects)):
		status_effects[i] = max(0.0, status_effects[i] - delta)
	var is_stunned := has_status_effect(StatusEffect.Kind.Stunned)
	if was_stunned and not is_stunned:
		# emit a signal to resume enemy logic
		_stun_ended.emit()
	
	_emit_signal_status_effects_changed(status_effects)
	
	stats = get_current_stats()
	
	if has_status_effect(StatusEffect.Kind.Regenerating):
		# get 5% of max HP per second
		health += 0.05 * stats.max_health * delta
	
	if has_status_effect(StatusEffect.Kind.Poisoned):
		# lose 300 HP per second
		health -= 300 * delta

	health = min(health, stats.max_health)
	
	# flip entity horizontally if going left.
	# since entity is a CharacterBody2D, we have to set scale.x = -1.
	if velocity.x < 0.0 and sprite_facing_right:
		sprite.scale.x = -1.0
		sprite_facing_right = false
	elif velocity.x > 0.0 and not sprite_facing_right:
		sprite.scale.x = 1.0
		sprite_facing_right = true

## Stats may change due to status effects.
## Use this function to get the current stats,
## taking into accunt all current status effects.
func get_current_stats() -> Stats:
	var max_health := base_stats.max_health
	var atk := base_stats.atk
	var def := base_stats.def
	var attack_speed := base_stats.attack_speed
	var movement_speed := base_stats.movement_speed
	
	# Enraged and Tenacious do the same thing
	# but are applied at different times.
	# Enraged = low HP, Tenacious = high HP
	if has_status_effect(StatusEffect.Kind.Enraged):
		attack_speed *= 1.8
		
	if has_status_effect(StatusEffect.Kind.Tenacious):
		atk *= 1.4
	
	if has_status_effect(StatusEffect.Kind.Frozen) or has_status_effect(StatusEffect.Kind.Stunned):
		movement_speed = 0.0
	elif has_status_effect(StatusEffect.Kind.Slowed):
		movement_speed *= 0.2
	
	# Regenerating, Invincible, Poisoned do not affect stats
	# Stunned also affects attacks (cannot attack)
	
	return Stats.new(max_health, atk, def, attack_speed, movement_speed)

func has_status_effect(kind: StatusEffect.Kind) -> bool:
	return status_effects[kind] > 0.0

## If [param should_replace] is [code]true[/code],
## any remaining duration is ignored and replaced with supplied duration.
## If [code]false[/code], then supplied duration is added onto existing duration.
## Defaults to [code]true[/code].
func receive_status_effect(kind: StatusEffect.Kind, duration: float, should_replace: bool = true) -> void:
	if should_replace:
		status_effects[kind] = duration
	else:
		status_effects[kind] += duration

func attack() -> void:
	# abstract function
	pass

func create_summon(summon_scene: Summon2D, args: Dictionary[String, Variant]) -> void:
	Signals.entity_request_create_summon.emit(summon_scene, args)

func take_damage(atk: int) -> void:
	if has_status_effect(StatusEffect.Kind.Invincible):
		# don't take damage when invincible
		return

	health -= (atk - stats.def)

func take_healing(atk: int) -> void:
	health += atk

# TODO: if these methods aren't needed (no more complicated logic
# separating player and enemy signals), remove these methods
func _emit_signal_health_changed(new_health: float) -> void:
	Signals.entity_health_changed.emit(self, new_health)

func _emit_signal_status_effects_changed(new_status_effects: Array[float]) -> void:
	Signals.entity_status_effects_changed.emit(self, new_status_effects)

func _emit_signal_died() -> void:
	Signals.entity_died.emit(self)
