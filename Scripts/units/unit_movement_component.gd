extends Node
class_name UnitMovementComponent

## The character component used to move along path

@export var speed: float = 5.0
@export var lookahead: float = 1.5 ## calculate next point by currentPositionOnPath + lookahead
@export var turn_speed : float = 0.75


## Move unit along path [br]
## move_forward: true if move along path, false if move in reverse [br]
## side_offset: lane to keep along the path (negative = left, positive = right, 0 = center)
func move(unit: CharacterBody3D, path: Path3D, move_forward: bool, side_offset: float = 0.0) -> void:
	# move along path by lookahead
	var lookahead_value: float = lookahead if move_forward else -lookahead
	var direction := MovementUtilities.get_path_direction(path, unit.global_position, lookahead_value, side_offset)
	if direction:
		unit.velocity.x = direction.x * speed
		unit.velocity.z = direction.z * speed
	else:
		unit.velocity.x = move_toward(unit.velocity.x, 0, speed)
		unit.velocity.z = move_toward(unit.velocity.z, 0, speed)
	
	# rotate towards velocity
	if (unit.velocity.length() > 0) :
		var target_basis = Basis.looking_at(unit.velocity)
		unit.basis = unit.basis.slerp(target_basis, turn_speed)
	
	unit.move_and_slide()


## Stop movement
func stop(unit: CharacterBody3D) -> void:
	unit.velocity = Vector3.ZERO


## Return distance to start or end path [br]
## move_forward: true, return length to end of the path; false, return length to the start
func get_to_end_distance(unit: CharacterBody3D, path: Path3D, move_forward: bool) -> float:
	# distance to start or end path
	var path_pos: Vector3 = MovementUtilities.get_path_end_position(path) if move_forward else MovementUtilities.get_path_start_position(path)
	var to_end: Vector3 = path_pos - unit.global_position
	to_end.y = 0.0 # ignore y
	return to_end.length()