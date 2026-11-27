@tool
extends Node
class_name PathGenerator

## Editor tool to create and destroy the paths between MapNodes. [br]
## Put the MapNodes in scene, set two of them in start_node and end_node, and press the buttons

@export_group("MUST BE SET")
@export var update_paths_in_update: bool = true ## If true, when user move a MapNode, the paths positions are updated with it
@export var map_path_prefab: PackedScene ## MapPath

@export_group("Path")
## node at the start of the path
@export var start_node: MapNode: 
	set(value):
		start_node = value
		# update also faction
		if start_node:
			start_faction = start_node.default_faction

## node at the end of the path
@export var end_node: MapNode: 
	set(value):
		end_node = value
		# update also faction
		if end_node:
			end_faction = end_node.default_faction

## Create a path between the two nodes
@export_tool_button("Generate path", "Curve3D") var generate_path_button: Callable = generate_path
## Destroy the path between the two nodes
@export_tool_button("Destroy path", "Remove") var destroy_path_button: Callable = destroy_path

@export_group("Factions")
## show and edit the faction in the start node
@export var start_faction: UnitUtilities.ECharacterFaction

## show and edit the faction in the end node
@export var end_faction: UnitUtilities.ECharacterFaction

## Show in editor the towers of the two nodes, based on their faction
@export_tool_button("Update towers", "MeshInstance3D") var update_towers_button: Callable = update_towers




func _ready() -> void:
	# update only in editor
	set_process(Engine.is_editor_hint())


func _process(_delta: float) -> void:
	# only if true
	if not update_paths_in_update:
		return
	# only in scene
	var root: Node = get_tree().edited_scene_root
	if root == null:
		return
	# keep paths always connected when move nodes
	for path: MapPath in root.find_children("*", "MapPath"):
		if path.start_node and path.end_node and path.curve and path.curve.point_count >= 2:
			_move_point(path, 0, path.start_node)
			_move_point(path, path.curve.point_count - 1, path.end_node)


func _move_point(path: MapPath, index: int, node: MapNode) -> void:
	# update curve point position to match the MapNode
	if node.is_inside_tree() and not path.to_local(node.global_position).is_equal_approx(path.curve.get_point_position(index)):
		path.curve.set_point_position(index, path.to_local(node.global_position))


#region buttons

## Create a path between the two nodes
func generate_path() -> void:
	if not start_node or not end_node or start_node == end_node:
		push_warning("Missing StartNode or EndNode, or they are the same Node")
		return
	var current_path: MapPath = _get_path_between_nodes()
	if current_path:
		push_warning("These nodes are already connected by a path in their list: ", current_path)
		return

	# create path
	var path: MapPath = map_path_prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	path.start_node = start_node
	path.end_node = end_node
	start_node.add_sibling(path, true)
	path.owner = get_tree().edited_scene_root # nodes without owner aren't saved in scene

	# create a new curve. Set it when already complete, because two points in the same position give errors
	var curve: Curve3D = Curve3D.new()
	curve.add_point(path.to_local(start_node.global_position))
	curve.add_point(path.to_local(end_node.global_position))
	path.curve = curve

	# add to the nodes. NB set again the array, because the scene saves only values that are set
	start_node.paths = start_node.paths + [path]
	end_node.paths = end_node.paths + [path]
	_set_unsaved()


## Destroy the path between the two nodes
func destroy_path() -> void:
	var path: MapPath = _get_path_between_nodes()
	if path == null:
		push_warning("There isn't a path between the two nodes")
		return

	# filter to get every node path that isn't found "path"
	for node: MapNode in [start_node, end_node]:
		node.paths = node.paths.filter(func(p: MapPath) -> bool: return p != path)
	path.queue_free()
	_set_unsaved()


## Set faction on the two nodes, and recreate their towers
func update_towers() -> void:
	_update_tower(start_node, start_faction)
	_update_tower(end_node, end_faction)
	_set_unsaved()

#endregion


## Return if start_node and end_node have a path in common
func _get_path_between_nodes() -> MapPath:
	if start_node and end_node:
		for path: MapPath in start_node.paths:
			if end_node.paths.has(path):
				return path
	return null


## Destroy old tower and instantiate new one as child of this MapNode
func _update_tower(node: MapNode, faction: UnitUtilities.ECharacterFaction) -> void:
	if node == null:
		return
	# filter to return only OrphanUnit childs
	var towers: Array[Node] = node.get_children().filter(func(child: Node) -> bool: return child is OrphanUnit)
	# get correct prefab to instantiate
	var prefabs: Array[PackedScene] = [node.player_tower.troop_prefab, node.enemy_tower.troop_prefab, node.empty_tower.troop_prefab] # same order of the enum
	var prefab: PackedScene = prefabs[faction]

	# skip only if faction is right, 
	# there is only one or zero tower instantiated from this script, 
	# and the showed tower (already in MapNode prefab or instantiated from this script) was instantiated from the correct prefab
	var current_tower: Node3D = MapNode.get_placeholder_tower(node)
	var scene_towers: int = towers.filter(func(tower: Node) -> bool: return tower.owner != node).size()
	if node.default_faction == faction \
		and current_tower and scene_towers <= 1 \
		and current_tower.scene_file_path == prefab.resource_path:
		return

	# else, update the faction
	node.default_faction = faction

	# keep old tower position and rotation, so the new one replaces it where it was placed in scene
	var old_transform: Transform3D = current_tower.transform if current_tower else Transform3D.IDENTITY

	# destroy old tower and create the new one (in play they will be destroyed and recreated by MapNode)
	for tower: Node in towers:
		tower.free()

	var new_tower: Node = prefab.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	node.add_child(new_tower, true)
	new_tower.owner = get_tree().edited_scene_root
	(new_tower as Node3D).transform = old_transform


## Show the scene as modified. With get_singleton, because EditorInterface doesn't exist in the exported game
func _set_unsaved() -> void:
	Engine.get_singleton("EditorInterface").mark_scene_as_unsaved()
