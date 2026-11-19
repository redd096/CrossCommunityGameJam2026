class_name  MovementUtilities
## Various static functions to help with characters movement

## Return direction to next point along the path. [br]
## lookahead: calculate next point by "current position on path" + "lookahead"
static func get_path_direction(path: Path3D, lookahead: float, current_global_pos: Vector3) -> Vector3:
	# calculate where we are in the path
	var curve: Curve3D = path.curve
	var current_pos_local_to_path: Vector3 = path.to_local(current_global_pos)
	var current_progress: float = curve.get_closest_offset(current_pos_local_to_path)

	# calculate next position to reach
	var next_progress: float = minf(current_progress + lookahead, curve.get_baked_length())
	var next_pos_local_to_path: Vector3 = curve.sample_baked(next_progress)
	var next_pos_global: Vector3 = path.to_global(next_pos_local_to_path)

	# calculate only direction (ignore height)
	var direction: Vector3 = next_pos_global - current_global_pos
	direction.y = 0.0
	
	# if reached the end, stay still
	if direction.length() < 0.1:
		return Vector3.ZERO
	
	return direction.normalized()