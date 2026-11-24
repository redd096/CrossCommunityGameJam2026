extends Node3D
class_name MapNode

@export var nodes : Array[StructPathNode]
# tower prefabs
@export var emptyUnitPrefab : PackedScene
@export var playerUnitPrefab : PackedScene
@export var enemyUnitPrefab : PackedScene
# faction
@export var default_faction : OrphanUnit.ECharacterFaction

signal on_conquisted_node(new_faction: OrphanUnit.ECharacterFaction)

var selectedPath : StructPathNode ## player current selected path when reach this node
var currentUnit : OrphanUnit ## the tower on this node
var current_faction: OrphanUnit.ECharacterFaction
## key: path that starts from this node; value: Array[OrphanUnit] on this node/path
## the currentUnit (the tower) is not in this array
var current_units_on_this_node: Dictionary[Path3D, Array]


func _ready() -> void :
	current_faction = default_faction
	_recreate_tower()


func on_tower_destroyed(destroyer_faction: OrphanUnit.ECharacterFaction) -> void:
	# change faction and emit signal
	current_faction = destroyer_faction
	_recreate_tower()
	on_conquisted_node.emit(destroyer_faction)


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
