extends CharacterBody3D
## Test script: 
## - move with normal CharacterBody3D but follow Path3D direction
## - use side_offset to keep your "lane"
## - use avoidance_agent to avoid other bodies on the path

@export var path: Path3D
@export var speed: float = 4.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead
@export var side_offset: float = 0.0 ## distance from the path center (negative = left, positive = right, 0 = center)
@export var avoidance_agent: NavigationAgent3D ## units avoid each other (RVO avoidance, no navmesh needed)


func _ready() -> void:
	# register to events
	if avoidance_agent:
		avoidance_agent.velocity_computed.connect(_on_velocity_computed)


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

	# send the desired velocity to avoidance_agent, the movement happens in _on_velocity_computed
	NavigationServer3D.agent_set_velocity(avoidance_agent.get_rid(), velocity)


## Called by the NavigationAgent3D in the same physics frame, with the desired velocity adjusted to avoid the other agents
func _on_velocity_computed(safe_velocity: Vector3) -> void:
	# avoidance works only on the ground plane (XZ), ignore gravity (Y)
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z
	move_and_slide()
