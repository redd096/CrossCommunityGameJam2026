extends CharacterBody3D
## Test script: 
## - spawn at Path3D start
## - then move with normal CharacterBody3D but follow Path3D direction
## - if pushed away should move again inside the Path3D

@export var path: Path3D
@export var speed: float = 4.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead
@export var side_offset: float = 0.0 ## distance from the path center (negative = left, positive = right, 0 = center)


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
	var direction := MovementUtilities.get_path_direction(path, global_position, lookahead, side_offset)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
