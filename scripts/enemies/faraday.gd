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

@export_category("Eddy Current")
@export var eddy_current_initial_cooldown := 5.0
@export var eddy_current_cooldown := 15.0
@export var eddy_current_effect_duration := 8.0

@export_category("Magnetic Flux Cutting")
@export var magnetic_flux_cutting_initial_cooldown := 60.0
@export var magnetic_flux_cutting_cooldown := 90.0
## Ratio of healing rate (in HP/s) against player speed (in pixels/s).
## Keep in mind that the default player speed is 800 pixels/s.
## This means that, if this value is set to 0.5, Faraday will receive 400 HP/s
## if the player is moving at full speed.
@export var magnetic_flux_cutting_effect_strength := 1.0
@export var magnetic_flux_cutting_effect_duration := 8.0

@export_category("Faraday Cage")
@export var faraday_cage_initial_cooldown := 40.0
@export var faraday_cage_cooldown := 40.0
@export var faraday_cage_duration := 10.0
## HP loss per second if the player is not in the Faraday Cage.
@export var faraday_cage_strength := 200.0

@onready var cooldowns: Dictionary[String, float] = {
	"normal_attack": 0.0,
	"made_in_ohio": made_in_ohio_initial_cooldown,
	"ohio_bankai": ohio_bankai_initial_cooldown,
	"sigma_stare": sigma_stare_initial_cooldown,
	"star_platinum": star_platinum_initial_cooldown,
	"wonder_of_ohio": wonder_of_ohio_initial_cooldown,
	"eddy_current": eddy_current_initial_cooldown,
	"magnetic_flux_cutting": magnetic_flux_cutting_initial_cooldown,
	"faraday_cage": faraday_cage_initial_cooldown,
}

var using_sword_attack := false
## Debounce the player collision during sword-based attacks
var hit_player := false

var cutting_magnetic_flux_time := INF

func _ready() -> void:
	super()
	receive_status_effect(StatusEffect.Kind.Invincible, 5.5)

func _process(delta: float) -> void:
	super(delta)
	for key in cooldowns.keys():
		cooldowns[key] -= delta
	
	if using_sword_attack and not hit_player:
		if %SwordCollider.overlaps_body(player):
			if animation_player.is_playing() and animation_player.current_animation == "attacking_made_in_ohio":
				player.take_damage(stats.atk * made_in_ohio_damage_multiplier)
			else:
				player.take_damage(stats.atk)
			hit_player = true
	
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
	
	cutting_magnetic_flux_time += delta
	
	if cutting_magnetic_flux_time <= magnetic_flux_cutting_effect_duration:
		health += player.velocity.length() * magnetic_flux_cutting_effect_strength * delta

func update_state_machine() -> void:
	#print("thinking")
	using_sword_attack = false
	hit_player = false
	
	if player.global_position.distance_to(global_position) > catch_up_distance:
		state = State.Moving
		return
		
	for value in cooldowns.values():
		if value <= 0.0:
			state = State.Attacking
			return
	
	state = State.Moving

func attack() -> void:
	#print("attacking")
	var least_cooldown: String = cooldowns.keys()[0]
	
	for key in cooldowns.keys():
		var value = cooldowns[key]
		if value < cooldowns[least_cooldown]:
			least_cooldown = key
	
	#print(least_cooldown)
	
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
		"eddy_current":
			eddy_current()
			cooldowns.eddy_current = eddy_current_cooldown
		"magnetic_flux_cutting":
			magnetic_flux_cutting()
			cooldowns.magnetic_flux_cutting = magnetic_flux_cutting_cooldown
		"faraday_cage":
			faraday_cage()
			cooldowns.faraday_cage = faraday_cage_cooldown

func mark_using_sword_attack() -> void:
	using_sword_attack = true

func mark_end_sword_attack() -> void:
	using_sword_attack = false

func normal_attack() -> void:
	#print("normal attack")
	animation_player.play("attacking_normal")

func made_in_ohio() -> void:
	#print("made in ohio")
	# raycast to get suitable point behind player
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		player.global_position,
		player.global_position - Vector2.from_angle(player.attack_direction) * 100.0,
		1
	)
	var result = space_state.intersect_ray(query).get("position")
	if result != null:
		global_position = result
	else:
		global_position = player.global_position - Vector2.from_angle(player.attack_direction) * 100.0
	
	animation_player.play("attacking_made_in_ohio")

func ohio_bankai() -> void:
	#print("ohio bankai")
	animation_player.play("attacking_ohio_bankai")

func ohio_bankai_deal_damage() -> void:
	if %OhioBankaiCollider.overlaps_body(player):
		player.take_damage(stats.atk * ohio_bankai_damage_multiplier)

func sigma_stare() -> void:
	#print("sigma stare")
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
	#print("wonder_of_ohio")
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

func eddy_current() -> void:
	animation_player.play("attacking_eddy_current")
	player.receive_status_effect(StatusEffect.Kind.Slowed, eddy_current_effect_duration)

func magnetic_flux_cutting() -> void:
	cutting_magnetic_flux_time = 0.0
	animation_player.play("attacking_magnetic_flux_cutting")
	
func faraday_cage() -> void:
	var region: NavigationRegion2D = level.get_children().filter(func (x): return x is NavigationRegion2D)[0]
	var point := NavigationServer2D.region_get_random_point(region.get_rid(), 1, true)
	
	create_summon(
		"res://scenes/components/enemy_summons/faraday_cage.tscn",
		{
			"to": point,
			"duration": faraday_cage_duration,
			"player": player,
			"strength": faraday_cage_strength,
		}
	)
	
	animation_player.play("attacking_faraday_cage")
