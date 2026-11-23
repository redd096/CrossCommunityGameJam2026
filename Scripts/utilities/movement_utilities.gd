class_name  MovementUtilities
## Various static functions to help with characters movement


## Return path global start position
static func get_path_start_position(path: Path3D) -> Vector3:
	var local_pos: Vector3 = path.curve.sample_baked(0.0)
	return path.to_global(local_pos)


## Return path global end position
static func get_path_end_position(path: Path3D) -> Vector3:
	var local_pos: Vector3 = path.curve.sample_baked(path.curve.get_baked_length())
	return path.to_global(local_pos)


## Return global position at "progress" along the path, moved right of left by "side_offset" [br]
## progress: distance in meter along the path [br]
## side_offset: negative = left, positive = right, 0 = center
static func get_path_global_position(path: Path3D, progress: float, side_offset: float = 0.0) -> Vector3:
	# calculate the global transform of the progress position
	var t: Transform3D = path.global_transform * path.curve.sample_baked_with_rotation(progress)
	# move right or left by side_offset
	return t.origin + t.basis.x.normalized() * side_offset


## Return direction to next point along the path. [br]
## lookahead: calculate next point by "current position on path" + "lookahead" [br]
## side_offset: negative = left, positive = right, 0 = center,
static func get_path_direction(path: Path3D, current_global_position: Vector3, lookahead: float, side_offset: float = 0.0) -> Vector3:
	# calculate where we are in the path
	var curve: Curve3D = path.curve
	var current_pos_local_to_path: Vector3 = path.to_local(current_global_position)
	var current_progress: float = curve.get_closest_offset(current_pos_local_to_path)

	# calculate next position to reach
	var next_progress: float = minf(current_progress + lookahead, curve.get_baked_length())
	# var next_pos_local_to_path: Vector3 = curve.sample_baked(next_progress)
	# var next_global_position: Vector3 = path.to_global(next_pos_local_to_path)
	var next_global_position: Vector3 = get_path_global_position(path, next_progress, side_offset)

	# calculate only direction (ignore height)
	var direction: Vector3 = next_global_position - current_global_position
	direction.y = 0.0
	
	# if reached the end, stay still
	if direction.length() < 0.1:
		return Vector3.ZERO
	
	return direction.normalized()


## Return the slot offsets of a formation made of columns and rows [br]
## x = side offset (column, where negative is left and positive is right), y = distance (row) [br]
## unit_count: the number of units in this formation [br]
## spacing: distance between two units, both side by side and between rows [br]
## max_columns: max units side by side in a row
static func get_formation_offsets(unit_count: int, spacing: float, max_columns: int) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	var row: int = 0

	while offsets.size() < unit_count:
		# full rows have max_columns units, the last one only the remaining units
		var remaining_units: int = unit_count - offsets.size()
		var columns_in_this_row: int = mini(max_columns, remaining_units)

		# calculate to have column 0 at the left instead of the center
		# e.g. we have 10 columns and we want to stay in column 5, we must be in the center and not to the right
		var half_size: float = (columns_in_this_row - 1) / 2.0 * spacing
		for column_index: int in columns_in_this_row:
			var offset_to_the_right: float = column_index * spacing
			var side_offset: float = offset_to_the_right - half_size
			offsets.append(Vector2(side_offset, row * spacing))

		# move to next row
		row += 1

	return offsets
