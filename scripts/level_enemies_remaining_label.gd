extends Label

var enemies_dead := 0
var total_enemies := 0

func redraw() -> void:
	text = "ENEMIES DEFEATED: {defeated}/{total}".format({
		"defeated": enemies_dead,
		"total": total_enemies
	})

func _ready() -> void:
	Signals.level_loaded.connect(func (total_enemy_count: int):
		total_enemies = total_enemy_count
		redraw()
	)
	
	Signals.entity_died.connect(func (entity: Entity2D):
		if entity is Enemy2D:
			enemies_dead += 1
			redraw()
			
			if enemies_dead == total_enemies:
				Signals.level_won.emit()
	)
