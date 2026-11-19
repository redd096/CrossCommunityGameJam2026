extends CharacterBody3D
## Test script: 
## - spawn at Path3D start
## - then move with normal CharacterBody3D but follow Path3D direction
## - if pushed away should move again inside the Path3D

@export var path: Path3D
@export var speed: float = 4.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead


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
	var direction := get_path_direction()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


func get_path_direction() -> Vector3:
	# calculate where we are in the path
	var curve: Curve3D = path.curve
	var current_pos_local_to_path: Vector3 = path.to_local(global_position)
	var current_progress: float = curve.get_closest_offset(current_pos_local_to_path)

	# calculate next position to reach
	var next_progress: float = minf(current_progress + lookahead, curve.get_baked_length())
	var next_pos_local_to_path: Vector3 = curve.sample_baked(next_progress)
	var next_pos_global: Vector3 = path.to_global(next_pos_local_to_path)

	# calculate only direction (ignore height)
	var direction: Vector3 = next_pos_global - global_position
	direction.y = 0.0
	
	# if reached the end, stay still
	if direction.length() < 0.1:
		return Vector3.ZERO
	
	return direction.normalized()
