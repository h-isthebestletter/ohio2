extends PlayerSummon2D
class_name ExplodingCrystal

var atk: float
var multiplier: float
var exploded: bool

func initialize(args: Dictionary[String, Variant]) -> void:
	atk = args["atk"]
	multiplier = args["multiplier"]
	global_position = args["to"]
	exploded = false
	self_modulate = Color.WHITE

func explode() -> void:
	if exploded: return
	exploded = true
	
	self_modulate = Color.TRANSPARENT
	
	for body in $DetectOther.get_overlapping_bodies():
		if body is Enemy2D:
			body.take_damage(atk * multiplier)
	
	for area in $DetectOther.get_overlapping_areas():
		var parent = area.get_parent()
		if parent is ExplodingCrystal:
			parent.explode()
	
	$ShockwaveLarge.start_animation()
	$ShockwaveLarge.animation_completed.connect(func ():
		request_become_unused.emit(self)
	)

func _process(delta: float) -> void:
	for body in $DetectEnemy.get_overlapping_bodies():
		if body is Enemy2D:
			explode()
