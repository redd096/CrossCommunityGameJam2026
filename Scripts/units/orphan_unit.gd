extends CharacterBody3D
class_name OrphanUnit

## Base script for a Unit, used by towers

enum ECharacterFaction
{
	PLAYER,
	ENEMY,
	NONE
}

@export var faction: ECharacterFaction
@export var state_machine: UnitStateMachineComponent
@export var start_hp : float
@export var attack_damage : float

var current_map_node: MapNode
var current_hp : float


## Init the character to set its node and start position. This is extended from MovableOrphanUnit
func setup(map_node: MapNode) -> void:
	current_hp = start_hp
	current_map_node = map_node
	global_position = current_map_node.global_position


## Called when an enemy attacks this unit. Extended from MovableOrphanUnit [br]
func receive_attack(attacker_faction: ECharacterFaction, damage : float) -> void:
	current_hp = clamp(current_hp, 0.0, current_hp - damage)
	if (current_hp == 0.0):
		if current_map_node:
			current_map_node.on_tower_destroyed(attacker_faction)
