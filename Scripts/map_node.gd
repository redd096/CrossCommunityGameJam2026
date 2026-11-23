extends Node3D
class_name MapNode

enum EDefaultMapNodeUnit
{
	EMPTY,
	PLAYER,
	ENEMY
}

@export var nodes : Array[StructPathNode]
@export var emptyUnitPrefab : PackedScene
@export var playerUnitPrefab : PackedScene
@export var enemyUnitPrefab : PackedScene
@export var defaultUnitType : EDefaultMapNodeUnit
var selectedPath : StructPathNode
var currentUnit : OrphanUnit


func _ready() -> void :
	match (defaultUnitType) :
		EDefaultMapNodeUnit.EMPTY:
			currentUnit = emptyUnitPrefab.instantiate() as OrphanUnit
		EDefaultMapNodeUnit.PLAYER:
			currentUnit = playerUnitPrefab.instantiate() as OrphanUnit
		EDefaultMapNodeUnit.ENEMY:
			currentUnit = enemyUnitPrefab.instantiate() as OrphanUnit
	add_child(currentUnit)
	currentUnit.setup(self, false)

func get_next_path() -> Path3D :
	#var mapNode = get_node(nodes[0].mapNode) as MapNode
	var path = get_node(nodes[0].path) as Path3D
	return path
