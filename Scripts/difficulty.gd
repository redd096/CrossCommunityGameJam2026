extends Node
class_name Difficulty

## Used by DifficultyManager.
## When the Player conquisted one of the nodes, these values are set in EnemyManager.

## conquisting any of these nodes activates this difficulty
@export var trigger_nodes: Array[MapNode]
## replaces EnemyManager.spawnable_troops
@export var spawnable_troops: Array[EnemySpawnChance]
## replaces EnemyManager.spawn_interval
@export var spawn_interval: float = 2.0
