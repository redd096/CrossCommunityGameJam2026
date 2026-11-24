extends State
class_name EnemyIdleState

## This is the state when the enemy spawn or arrive to a node, and decide what to do

@export var check_targets_interval: float = 0.1 ## seconds between checks of Player units in attack range
@export var check_path_interval: float = 1.0 ## seconds between checks what to do (move along some path or defend)

var sm: EnemyStateMachineComponent
var current_node: MapNode

var _targets_timer: float = 0.0
var _path_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	current_node = sm.current_map_node

	# reset values (set completed timer to do immediatly first check)
	_targets_timer = check_targets_interval
	_path_timer = check_path_interval

	# arrived on an empty tower: conquer it immediately
	if current_node.current_faction == OrphanUnit.ECharacterFaction.NONE:
		current_node.on_tower_destroyed(sm.unit.faction)


func _process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if _check_targets():
			return

	# every few seconds, check what to do
	_path_timer += delta
	if _path_timer > check_path_interval:
		_path_timer = 0.0
		_check_paths()


func _check_targets() -> bool:
	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(OrphanUnit.ECharacterFaction.PLAYER):
		sm.set_state(sm.attack_state)
		return true
	
	return false


func _check_paths() -> void:
	# if there are player's units on the path to my current node, stay still and defend
	var defend_path: StructPathNode = _get_path_to_defend()
	if defend_path != null:
		sm.set_state(sm.defend_state)
		return
	
	# if there aren't player's units, find a tower to move to
	var move_path: StructPathNode = _get_next_path()
	if move_path != null:
		sm.set_new_node_and_path(current_node, move_path)
		sm.set_state(sm.move_state)
	
	# else, just wait to recheck what to do


func _get_next_path() -> StructPathNode:
	# if there is only one path, move to it
	if current_node.nodes.size() == 1:
		return current_node.nodes[0]

	# split paths to player towers and paths to empty towers
	var player_paths: Array[StructPathNode]
	var empty_paths: Array[StructPathNode]
	for struct_path: StructPathNode in current_node.nodes:
		var target_node: MapNode = current_node.get_map_node_from_struct(struct_path)
		if target_node.current_faction == OrphanUnit.ECharacterFaction.PLAYER:
			player_paths.append(struct_path)
		elif target_node.current_faction == OrphanUnit.ECharacterFaction.NONE:
			empty_paths.append(struct_path)
	
	# move to player's towers
	if not player_paths.is_empty():
		return _get_shorter_path_from_list(player_paths)	

	# if there aren't player tower, move to empty towers
	if not empty_paths.is_empty():
		return _get_shorter_path_from_list(empty_paths)	

	# if there aren't objectives near, draw a path from this tower to nearest tower with player or empty towers connected
	return _draw_path_to_enemy_tower_with_player_or_empty_near()


#region private api

## If there are player's units on the path to my current node, stay still and defend
func _get_path_to_defend() -> StructPathNode:
	# cycle every path from this node
	for struct_path: StructPathNode in current_node.nodes:
		var path: Path3D = current_node.get_path_from_struct(struct_path)
		var target_node: MapNode = current_node.get_map_node_from_struct(struct_path)
		# every unit on the same path but starting from target_node, are moving to this current_node
		var units_moving_to_current_node: Array = target_node.get_units_on_this_node(path)
		# if there is at least one Player unit, defend
		if units_moving_to_current_node.any(func(unit: OrphanUnit): return unit.faction == OrphanUnit.ECharacterFaction.PLAYER):
			return struct_path
	
	return null


func _get_shorter_path_from_list(list: Array[StructPathNode]) -> StructPathNode:
	var shortest: StructPathNode = null
	var shortest_length: float = INF

	for struct: StructPathNode in list:
		var path: Path3D = current_node.get_path_from_struct(struct)
		var length: float = path.curve.get_baked_length()
		if length < shortest_length:
			shortest_length = length
			shortest = struct
	
	return shortest


## Dijkstra algorithm on the whole map, starting from current_node.
## Returns the first path to take to reach the nearest PLAYER tower (it can pass through other towers too).
## If no player tower is reachable, returns the first path to the nearest EMPTY tower
func _draw_path_to_enemy_tower_with_player_or_empty_near() -> StructPathNode:
	# shortest known distance from current_node to every discovered node
	var distances: Dictionary[MapNode, float] = {current_node: 0.0}
	# for every discovered node, the first path to take from current_node to reach it
	var first_steps: Dictionary[MapNode, StructPathNode] = {}
	# nodes that we know for sure the shortests distance
	var visited: Dictionary[MapNode, bool] = {}
	# fallback if there aren't player towers reachable (the nearest tower empty)
	var nearest_empty: MapNode = null

	while true:
		# pick the closest node not visited yet
		var mapNode: MapNode = null
		for candidate: MapNode in distances:
			if not visited.has(candidate) and (mapNode == null or distances[candidate] < distances[mapNode]):
				mapNode = candidate
		# every reachable node was visited
		if mapNode == null:
			break
		visited[mapNode] = true

		if mapNode != current_node:
			## FOUND NEAREST PLAYER TOWER
			if mapNode.current_faction == OrphanUnit.ECharacterFaction.PLAYER:
				return first_steps[mapNode]
			# remember the nearest empty tower, but keep searching for a player tower
			if mapNode.current_faction == OrphanUnit.ECharacterFaction.NONE and nearest_empty == null:
				nearest_empty = mapNode
				#IF WE DECIDE THAT THE NEAREST EMPTY TOWER IS OKAY, RETURN HERE, INSTEAD OF LOOK FOR THE PLAYER TOWER

		# update distances of the connected nodes
		for struct_path: StructPathNode in mapNode.nodes:
			var neighbour: MapNode = mapNode.get_map_node_from_struct(struct_path)
			var distance: float = distances[mapNode] + mapNode.get_path_from_struct(struct_path).curve.get_baked_length()
			if distance < distances.get(neighbour, INF):
				distances[neighbour] = distance
				# from current_node the first step is the path itself, otherwise inherit it from the previous node
				first_steps[neighbour] = struct_path if mapNode == current_node else first_steps[mapNode]

	# FALLBACK NEAREST EMPTY TOWER
	if nearest_empty != null:
		return first_steps[nearest_empty]

	return null

#endregion
