extends CharacterBody3D
## Test script: 
## - spawn at Path3D start
## - then move with normal CharacterBody3D but follow Path3D direction
## - if pushed away should move again inside the Path3D
## - if find enemy along the path, stop

@export var path: Path3D
@export var speed: float = 4.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead

@export var area_debug: MeshInstance3D
@export var radius_find_enemy: float = 4.0
@export_flags_3d_physics var enemy_layer: int = 1<<(3-1) # default enemy layer is 3, to get its value in bit we do 1<<(layer-1)


func _ready() -> void:
	# spawn at Path3D start
	global_position = path.to_global(path.curve.sample_baked(0.0))


# copy-paste from CharacterBody3D code in godot
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# # Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# # Get the input direction and handle the movement/deceleration.
	# # As good practice, you should replace UI actions with custom gameplay actions.
	# var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var direction := MovementUtilities.get_path_direction(path, lookahead, global_position)

	# debug area
	var sphere: SphereMesh = area_debug.mesh
	sphere.radius = radius_find_enemy
	sphere.height = radius_find_enemy * 2.0
	# stop if find enemy
	if FightUtilities.find_target(self, radius_find_enemy, enemy_layer) != null:
		direction = Vector3.ZERO

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
