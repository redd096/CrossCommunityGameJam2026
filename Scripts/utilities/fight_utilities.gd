class_name FightUtilities
## Various static functions to help with characters fight


## Return the list of targets in this radius [br]
## caller: who is looking for targets (could be the minion or a throwed bomb) [br]
## target_layer: enemy layer when called from player's character, or player layer when called from enemies
static func find_targets(caller: Node3D, radius: float, target_layer: int) -> Array[Node3D]:
	# get hits with sphere cast
	var hits: Array[Dictionary] = _spherecast_3d(caller, caller.global_position, Vector3.ZERO, radius, target_layer)

	# create a list of Node3D from it
	var node_3d_hits: Array[Node3D]
	for hit: Dictionary in hits:
		node_3d_hits.append(hit.collider)

	return node_3d_hits


## Return the best target in this radius [br]
## caller: who is looking for target (could be the minion or a throwed bomb) [br]
## target_layer: enemy layer when called from player's character, or player layer when called from enemies
static func find_target(caller: Node3D, radius: float, target_layer: int) -> Node3D:
	var list: Array[Node3D] = find_targets(caller, radius, target_layer)
	return _get_best_target_in_list(caller.global_position, list)


## Return the list of targets in this area
static func find_targets_in_area(area: Area3D) -> Array[Node3D]:
	return area.get_overlapping_bodies()


## Return the best target in this area
static func find_target_in_area(area: Area3D) -> Node3D:
	return _get_best_target_in_list(area.global_position, area.get_overlapping_bodies())


#region private api


## For now just find target by distance, in the future could check some priority
static func _get_best_target_in_list(current_global_position: Vector3, list: Array[Node3D]) -> Node3D:
	return _get_closest_in_list(current_global_position, list)


## Return the closest body inside the list
static func _get_closest_in_list(current_global_position: Vector3, list: Array[Node3D]) -> Node3D:
	var closest: Node3D = null
	var closest_dist: float = INF

	for body: Node3D in list:
		var dist: float = current_global_position.distance_squared_to(body.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest = body
	
	return closest


## Same as Physics.SphereCast in unity, or Physics.OverlapSphere if "to" is Vector3.ZERO 
## (same as ShapeCast3D and Area3D nodes)
static func _spherecast_3d(caller: Node3D, from: Vector3, to: Vector3, radius: float, collision_mask: int = 4294967295, exclude: Array[RID] = []) -> Array[Dictionary]:
	var space := caller.get_world_3d().direct_space_state
	# create shape
	var shape = SphereShape3D.new()
	shape.radius = radius
	# create query
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.transform = Transform3D(Basis.IDENTITY, from)
	query.motion = to - from
	query.collision_mask = collision_mask
	query.exclude = exclude
	return space.intersect_shape(query)


#endregion
