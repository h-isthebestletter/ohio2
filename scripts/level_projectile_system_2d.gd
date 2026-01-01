# UNUSED SCRIPT, KEPT HERE BECAUSE I PUT A LOT OF EFFORT INTO IT (lol)

extends MultiMeshInstance2D
class_name ProjectileSystem2D

# NOTE!!!
# The mesh used as the MeshInstance is NOT THE QUADMESH OR PLANEMESH!!!
# Those are designed to be 2D meshes. Instead we have to generate a 2D square mesh
# by creating a sprite with the wanted texture, switching to 2D view,
# then converting the sprite to a mesh and copy-and-pasting that mesh into the blank.
# This also means that there is no easy way to adjust the size of the projectile
# in the editor.

# Projectiles have a destination. They will not collide with anything else
# and will only take effect once they reach their destination.
# They have a noticeable travel time.

# Changing the instance_count directly leads to the MultiMeshInstance2D blinking
# whenever the instance_count is increased. Instead we fix it to a high ceiling
# and change visible_instance_count.
const MAX_PROJECTILES = 256

@export var should_projectile_face_velocity: Array[bool]
@export var should_projectile_ascend: Array[bool]

class ProjectileData2D:
	var texture_id: int
	var origin: Vector2
	var position: Vector2
	var destination: Vector2
	var speed: float
	var should_face_velocity: bool
	var should_ascend: bool
	var landed: bool
	var landed_callback: Callable
	
	func _init(
		texture_id: int,
		position: Vector2,
		destination: Vector2,
		speed: float,
		on_landed: Callable,
		should_projectile_face_velocity: Array[bool],
		should_projectile_ascend: Array[bool],
	):
		self.texture_id = texture_id
		self.origin = position
		self.position = position
		self.destination = destination
		self.speed = speed
		self.landed_callback = on_landed
		self.should_face_velocity = should_projectile_face_velocity[texture_id]
		self.should_ascend = should_projectile_ascend[texture_id]
		self.landed = false

	func get_transform() -> Transform2D:
		var rotation: float
		if not should_face_velocity:
			rotation = 0.0
		elif speed < 0.00001:
			rotation = 0.0
		else:
			var delta = destination - position
			rotation = atan2(delta.y, delta.x)
		
		var ascended_position
		if not should_ascend:
			ascended_position = position
		else:
			ascended_position = (origin - position).length() * (destination - position).length() * Vector2(0, -0.0005) + position
		return Transform2D(rotation, ascended_position)

var projectiles: Array[ProjectileData2D] = []

func _ready() -> void:
	multimesh.instance_count = MAX_PROJECTILES
	multimesh.visible_instance_count = 0

func _process(delta: float) -> void:
	for projectile in projectiles:
		update_projectile(projectile, delta)
	
	sync_projectile_array_to_multimesh_buffer()
	
func add_projectile(texture_id: int, position: Vector2, destination: Vector2, speed: float, on_landed: Callable) -> void:
	projectiles.append(
		ProjectileData2D.new(
			texture_id, position, destination, speed, on_landed,
			should_projectile_face_velocity, should_projectile_ascend
		)
	)
	sync_projectile_array_to_multimesh_buffer()

func remove_projectile(projectile_id: int) -> void:
	multimesh.visible_instance_count -= 1
	projectiles.remove_at(projectile_id)

func update_projectile(projectile: ProjectileData2D, time_delta: float) -> void:
	var distance_to_destination = (projectile.destination - projectile.position).length()
	if distance_to_destination < projectile.speed:
		projectile.landed = true
		projectile.landed_callback.call(projectile.destination)
	else:
		projectile.position += (projectile.destination - projectile.position).normalized() * projectile.speed * time_delta

	projectiles = projectiles.filter(func (x): return not x.landed)

func sync_projectile_array_to_multimesh_buffer() -> void:
	# multimesh.visible_instance_count = 0
	for projectile_id in range(len(projectiles)):
		var projectile = projectiles[projectile_id]
		multimesh.set_instance_custom_data(projectile_id, Color(0, 0, 0, projectile.texture_id))
		multimesh.set_instance_transform_2d(projectile_id, projectile.get_transform())
	multimesh.visible_instance_count = len(projectiles)
