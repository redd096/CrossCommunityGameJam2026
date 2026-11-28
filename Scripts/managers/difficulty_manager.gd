extends Node
class_name DifficultyManager

## Increases the difficulty when the Player conquisted some nodes

@export var enemy_manager: EnemyManager

## Put difficulties in order. When reach one difficulty, can't go back to previous ones
@export var difficulties: Array[Difficulty]

# start from -1 so can enter in difficulties[0] when conquist first node
var current_difficulty_index: int = -1

func _ready() -> void:
	# register to any node "conquisted" event
	for index: int in difficulties.size():
		var difficulty: Difficulty = difficulties[index]
		for map_node: MapNode in difficulty.trigger_nodes:
			if map_node == null:
				push_warning("DifficultyManager: empty element in trigger_nodes of " + difficulty.name)
				continue
			map_node.on_conquisted_node.connect(_on_conquisted_node.bind(index))


func _on_conquisted_node(new_faction: UnitUtilities.ECharacterFaction, difficulty_index: int) -> void:
	# if conquisted by player
	if new_faction == UnitUtilities.ECharacterFaction.PLAYER:
		# if this is greater then current difficulty
		if difficulty_index > current_difficulty_index:
			# update enemy manager
			var difficulty: Difficulty = difficulties[difficulty_index]
			enemy_manager.spawnable_troops = difficulty.spawnable_troops
			enemy_manager.spawn_interval = difficulty.spawn_interval
