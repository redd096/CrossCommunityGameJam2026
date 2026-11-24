extends Node3D
class_name MapNode

@export var default_faction : OrphanUnit.ECharacterFaction

@export_group("Paths from this node")
## every possible path from this node
@export var nodes : Array[StructPathNode]

@export_group("Tower prefabs")
@export var emptyUnitPrefab : PackedScene 	## OrphaUnit
@export var playerUnitPrefab : PackedScene	## OrphaUnit
@export var enemyUnitPrefab : PackedScene	## OrphaUnit

@export_group("Arrow Path")
@export var arrowPrefab : PackedScene ## PathPlayerSelector
@export var arrow_distance : float = 2.5 ## distance from this node, in meter along the path

signal on_conquisted_node(new_faction: OrphanUnit.ECharacterFaction)

var selectedPath : StructPathNode ## path selected by the player, null when there isn't one or this node is no more of the player
var currentUnit : OrphanUnit ## the tower on this node
var arrows : Array[PathPlayerSelector] ## one for every path
var current_faction: OrphanUnit.ECharacterFaction
## key: path that starts from this node; value: Array[OrphanUnit] on this node/path
## the currentUnit (the tower) is not in this array
var current_units_on_this_node: Dictionary[Path3D, Array]


func _ready() -> void:
	current_faction = default_faction
	_recreate_tower()
	# create disabled arrows
	_create_arrows()
	_update_arrows()


func on_tower_destroyed(destroyer_faction: OrphanUnit.ECharacterFaction) -> void:
	# change faction and emit signal
	current_faction = destroyer_faction
	_recreate_tower()
	on_conquisted_node.emit(destroyer_faction)
	# and disable selected path
	set_selected_path(null)


func _recreate_tower() -> void:
	# destroy previous tower
	if currentUnit:
		currentUnit.queue_free()

	# instantiate tower and initialize
	match (current_faction):
		OrphanUnit.ECharacterFaction.NONE:
			currentUnit = emptyUnitPrefab.instantiate() as OrphanUnit
		OrphanUnit.ECharacterFaction.PLAYER:
			currentUnit = playerUnitPrefab.instantiate() as OrphanUnit
		OrphanUnit.ECharacterFaction.ENEMY:
			currentUnit = enemyUnitPrefab.instantiate() as OrphanUnit
	add_child(currentUnit)
	currentUnit.setup(self)


#region player selected path

## Set the path that player's units on this node must follow
func set_selected_path(struct: StructPathNode) -> void:
	selectedPath = struct
	_update_arrows()


func _create_arrows() -> void:
	# create an arrow for every path
	for struct: StructPathNode in nodes:
		var arrow: PathPlayerSelector = arrowPrefab.instantiate() as PathPlayerSelector
		add_child(arrow)
		arrow.setup(self, struct, arrow_distance)
		arrows.append(arrow)


func _update_arrows() -> void:
	for arrow: PathPlayerSelector in arrows:
		# show arrows only if the node is of the player
		arrow.set_active(current_faction == OrphanUnit.ECharacterFaction.PLAYER)
		# and highlight selected one
		arrow.set_selected(arrow.struct_path == selectedPath)

#endregion


#region units on node

func get_units_on_this_node(path: Path3D) -> Array[OrphanUnit]:
	_init_units_on_this_node_dictionary(path)
	return current_units_on_this_node[path]


func add_unit_to_this_node(unit: OrphanUnit, struct: StructPathNode) -> void:
	var path: Path3D = get_path_from_struct(struct)
	_init_units_on_this_node_dictionary(path)
	current_units_on_this_node[path].append(unit)


func remove_unit_from_this_node(unit: OrphanUnit, struct: StructPathNode) -> void:
	var path: Path3D = get_path_from_struct(struct)
	_init_units_on_this_node_dictionary(path)
	current_units_on_this_node[path].erase(unit)


func _init_units_on_this_node_dictionary(path: Path3D) -> void:
	if not current_units_on_this_node.has(path):
		# typed var, so the dictionary understand it is a typed Array[OrphanUnit] and not a generic Array
		var units: Array[OrphanUnit] = []
		current_units_on_this_node[path] = units

#endregion


#region utils to get values from StructPathNode

func get_path_from_struct(struct: StructPathNode) -> Path3D:
	return get_node(struct.path)


func get_map_node_from_struct(struct: StructPathNode) -> MapNode:
	return get_node((struct.mapNode))

#endregion
