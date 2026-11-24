extends State
class_name PlayerIdleState

## State when unit is on a node and wait for Player to select a path to start move
## If there is only one path, don't wait for Player to select it

var sm: PlayerStateMachineComponent
var current_node: MapNode

const CHECK_INTERVAL: float = 1.0
var _check_timer: float


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent
	current_node = sm.current_map_node

	# reset values
	_check_timer = 0.0

	# arrived on an empty tower: conquer it immediately
	if current_node.current_faction == OrphanUnit.ECharacterFaction.NONE:
		current_node.on_tower_destroyed(sm.unit.faction)


func _process_state(delta: float) -> void:
	# every few seconds, check what to do
	_check_timer += delta
	if _check_timer > CHECK_INTERVAL:
		_check_timer = 0.0
		_check_what_to_do()


func _check_what_to_do() -> void:
	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(OrphanUnit.ECharacterFaction.PLAYER):
		sm.set_state(sm.attack_state)
		return

	# else, find a tower to move to
	var move_path: StructPathNode = get_next_path()
	if move_path != null:
		sm.set_new_node_and_path(current_node, move_path)
		sm.set_state(sm.move_state)
	
	# else, just wait to recheck what to do


func get_next_path() -> StructPathNode:
	# if there is only one path, move to it
	if current_node.nodes.size() == 1:
		return current_node.nodes[0]

	# split paths to enemy towers and paths to empty towers
	var enemy_paths: Array[StructPathNode]
	var empty_paths: Array[StructPathNode]
	for struct_path: StructPathNode in current_node.nodes:
		var target_node: MapNode = current_node.get_map_node_from_struct(struct_path)
		if target_node.current_faction == OrphanUnit.ECharacterFaction.ENEMY:
			enemy_paths.append(struct_path)
		elif target_node.current_faction == OrphanUnit.ECharacterFaction.NONE:
			empty_paths.append(struct_path)
	
	# move to enemy's towers
	if not enemy_paths.is_empty():
		return _get_shorter_path_from_list(enemy_paths)	

	# if there aren't enemy tower, move to empty towers
	if not empty_paths.is_empty():
		return _get_shorter_path_from_list(empty_paths)	

	# if there aren't objectives near, draw a path from this tower to nearest tower with enemy or empty towers connected
	return _draw_path_to_enemy_tower_with_enemy_or_empty_near()


#region private api


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
## Returns the first path to take to reach the nearest ENEMY tower (it can pass through other towers too).
## If no enemy tower is reachable, returns the first path to the nearest EMPTY tower
func _draw_path_to_enemy_tower_with_enemy_or_empty_near() -> StructPathNode:
	# shortest known distance from current_node to every discovered node
	var distances: Dictionary[MapNode, float] = {current_node: 0.0}
	# for every discovered node, the first path to take from current_node to reach it
	var first_steps: Dictionary[MapNode, StructPathNode] = {}
	# nodes that we know for sure the shortests distance
	var visited: Dictionary[MapNode, bool] = {}
	# fallback if there aren't enemy towers reachable (the nearest tower empty)
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
			## FOUND NEAREST ENEMY TOWER
			if mapNode.current_faction == OrphanUnit.ECharacterFaction.ENEMY:
				return first_steps[mapNode]
			# remember the nearest empty tower, but keep searching for a enemy tower
			if mapNode.current_faction == OrphanUnit.ECharacterFaction.NONE and nearest_empty == null:
				nearest_empty = mapNode
				#IF WE DECIDE THAT THE NEAREST EMPTY TOWER IS OKAY, RETURN HERE, INSTEAD OF LOOK FOR THE ENEMY TOWER

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