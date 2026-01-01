class_name StatusEffect

enum Kind {
	## Increased attack speed when below certain %HP.
	Enraged,
	## Regenerates certain %HP per second.
	Regenerating,
	## Movement speed is decreased.
	Slowed,
	## Cannot be damaged.
	Invincible,
	## Cannot move.
	Frozen,
	## Increased ATK when above certain %HP.
	Tenacious,
	## Takes flat amount of damage per second.
	Poisoned,
	## Cannot move nor attack.
	Stunned,
}
