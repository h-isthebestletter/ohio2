extends Enemy2D

## If the player is this number of pixels away, enemy will be forced to move.
@export var catch_up_distance := 2000.0

@export_category("Normal attack")
@export var normal_attack_cooldown := 2.0

@export_category("Made in Ohio")
@export var made_in_ohio_initial_cooldown := 5.0
@export var made_in_ohio_cooldown := 20.0
@export var made_in_ohio_damage_multiplier := 1.1

@export_category("Ohio Bankai")
@export var ohio_bankai_initial_cooldown := 30.0
@export var ohio_bankai_cooldown := 50.0
@export var ohio_bankai_damage_multiplier := 1.7

@export_category("Sigma Stare")
@export var sigma_stare_initial_cooldown := 15.0
@export var sigma_stare_cooldown := 15.0
@export var sigma_stare_range := 3000.0

@export_category("Star Platinum")
@export var star_platinum_initial_cooldown := 40.0
@export var star_platinum_cooldown := 40.0
@export var freeze_duration := 5.0

@export_category("Wonder of Ohio")
@export var wonder_of_ohio_initial_cooldown := 20.0
@export var wonder_of_ohio_cooldown := 60.0
@export var wonder_of_ohio_damage_multiplier := 2.0
@export_range(0.0, 360.0, 0.01, "degrees") var planet_approach_angle := 100.0
@export var planet_speed := 3600.0

@onready var cooldowns: Dictionary[String, float] = {
	"normal_attack": 0.0,
	"made_in_ohio": made_in_ohio_initial_cooldown,
	"ohio_bankai": ohio_bankai_initial_cooldown,
	"sigma_stare": sigma_stare_initial_cooldown,
	"star_platinum": star_platinum_initial_cooldown,
	"wonder_of_ohio": wonder_of_ohio_initial_cooldown,
}

func _ready() -> void:
	super()
	receive_status_effect(StatusEffect.Kind.Invincible, 5.5)

func _process(delta: float) -> void:
	super(delta)
	for key in cooldowns.keys():
		cooldowns[key] -= delta
	
	if animation_player.is_playing() and animation_player.current_animation == "attacking_sigma_stare":
		%SigmaStareRaycast.target_position = (player.global_position - global_position).normalized() * sigma_stare_range
		%SigmaStareRaycast.force_raycast_update()
		%SigmaStareRay.points[1] = %SigmaStareRaycast.get_collision_point() - global_position
		if %SigmaStareRaycast.get_collider() is Player2D:
			player.receive_status_effect(StatusEffect.Kind.Poisoned, INF)
		else:
			player.receive_status_effect(StatusEffect.Kind.Poisoned, 0.0)
	elif %SigmaStareRaycast.enabled:
		player.receive_status_effect(StatusEffect.Kind.Poisoned, 0.0)
		%SigmaStareRay.points[1] = Vector2.ZERO
		%SigmaStareRaycast.enabled = false

func update_state_machine() -> void:
	if player.global_position.distance_to(global_position) > catch_up_distance:
		state = State.Moving
		return
		
	for value in cooldowns.values():
		if value <= 0.0:
			state = State.Attacking
			return
	
	state = State.Moving

func attack() -> void:
	var least_cooldown: String = cooldowns.keys()[0]
	
	for key in cooldowns.keys():
		var value = cooldowns[key]
		if value < cooldowns[least_cooldown]:
			least_cooldown = key
	
	match least_cooldown:
		"normal_attack":
			normal_attack()
			cooldowns.normal_attack = normal_attack_cooldown
		"made_in_ohio":
			made_in_ohio()
			cooldowns.made_in_ohio = made_in_ohio_cooldown
		"ohio_bankai":
			ohio_bankai()
			cooldowns.ohio_bankai = ohio_bankai_cooldown
		"sigma_stare":
			sigma_stare()
			cooldowns.sigma_stare = sigma_stare_cooldown
		"star_platinum":
			star_platinum()
			cooldowns.star_platinum = star_platinum_cooldown
		"wonder_of_ohio":
			wonder_of_ohio()
			cooldowns.wonder_of_ohio = wonder_of_ohio_cooldown

func normal_attack() -> void:
	animation_player.play("attacking_normal")

func normal_attack_deal_damage() -> void:
	for body in %NormalAttackCollider.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(stats.atk)
			return

func made_in_ohio() -> void:
	# raycast to get suitable point behind player
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		player.global_position,
		player.global_position - Vector2.from_angle(player.attack_direction) * 50.0,
		1
	)
	var result = space_state.intersect_ray(query).get("position")
	if result != null:
		global_position = result
	else:
		global_position = player.global_position - Vector2.from_angle(player.attack_direction) * 50.0
	
	animation_player.play("attacking_made_in_ohio")

func made_in_ohio_deal_damage() -> void:
	for body in %MadeInOhioCollider.get_overlapping_bodies():
		if body is Player2D:
			body.take_damage(stats.atk * made_in_ohio_damage_multiplier)
			return

func ohio_bankai() -> void:
	animation_player.play("attacking_ohio_bankai")

func ohio_bankai_deal_damage() -> void:
	if %OhioBankaiCollider.overlaps_body(player):
		player.take_damage(stats.atk * ohio_bankai_damage_multiplier)

func sigma_stare() -> void:
	animation_player.play("attacking_sigma_stare")
	%SigmaStareRaycast.enabled = true

func star_platinum() -> void:
	animation_player.play("attacking_star_platinum")
	create_summon(
		"res://scenes/components/enemy_summons/freeze_zone.tscn",
		{
			"quadrant": randi_range(1, 4),
			"duration": freeze_duration,
			"player": player,
			"position": player.global_position,
		}
	)

func wonder_of_ohio() -> void:
	animation_player.play("attacking_wonder_of_ohio")
	create_summon(
		"res://scenes/components/enemy_summons/jupiter.tscn",
		{
			"approach_angle": deg_to_rad(planet_approach_angle),
			"to": player.global_position,
			"speed": planet_speed,
			"atk": stats.atk * wonder_of_ohio_damage_multiplier,
		}
	)
