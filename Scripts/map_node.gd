extends Node3D
class_name MapNode

enum EDefaultMapNodeUnit
{
	EMPTY,
	PLAYER,
	ENEMY
}

@export var nodes : Array[StructPathNode]
# tower prefabs
@export var emptyUnitPrefab : PackedScene
@export var playerUnitPrefab : PackedScene
@export var enemyUnitPrefab : PackedScene
# faction
@export var defaultUnitType : EDefaultMapNodeUnit

var selectedPath : StructPathNode
var currentUnit : OrphanUnit
var current_unit_type: EDefaultMapNodeUnit


func _ready() -> void :
	current_unit_type = defaultUnitType
	match (defaultUnitType):
		EDefaultMapNodeUnit.EMPTY:
			currentUnit = emptyUnitPrefab.instantiate() as OrphanUnit
		EDefaultMapNodeUnit.PLAYER:
			currentUnit = playerUnitPrefab.instantiate() as OrphanUnit
		EDefaultMapNodeUnit.ENEMY:
			currentUnit = enemyUnitPrefab.instantiate() as OrphanUnit
	add_child(currentUnit)
	currentUnit.setup(self, false)


func get_next_struct_path() -> StructPathNode:
	var path = nodes[0]
	return path

func get_path_from_struct(struct: StructPathNode) -> Path3D:
	return get_node(struct.path)

func get_map_node_from_struct(struct: StructPathNode) -> MapNode:
	return get_node((struct.mapNode))
