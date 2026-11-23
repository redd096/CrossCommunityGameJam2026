extends Node3D
class_name MapNode

enum DefaultMapNodeUnit
{
	NONE,
	PLAYER,
	ENEMY
}

@export var nodes : Array[StructPathNode]
@export var playerPrefab : Array[PackedScene]
@export var enemyPrefab : Array[PackedScene]
@export var emptyPrefab : Array[PackedScene]
@export var defaultUnit : DefaultMapNodeUnit 
var selectedPath : StructPathNode
var currentUnit : OrphanUnit


func get_next_path() -> Path3D :
	var mapNode = get_node(nodes[0].mapNode) as MapNode
	var path = get_node(nodes[0].path) as Path3D
	return path
