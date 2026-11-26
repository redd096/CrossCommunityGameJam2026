extends CharacterBody3D
class_name OrphanUnit

## Base script for a Unit
@export var state_machine: UnitStateMachineComponent

var current_hp : float
var faction: UnitUtilities.ECharacterFaction
var attack_damage : float
var current_map_node: MapNode


## Init the character to set its node and start position. This is extended from MovableOrphanUnit
func setup(troop_resource: TroopResource, map_node: MapNode) -> void:
	faction = troop_resource.faction
	current_hp = troop_resource.start_hp
	attack_damage = troop_resource.attack_damage
	current_map_node = map_node
	global_position = current_map_node.global_position

	if (state_machine):
		state_machine.setup(map_node, Vector2.ZERO)

## Called when an enemy attacks this unit. Extended from MovableOrphanUnit [br]
func receive_attack(attacker_faction: UnitUtilities.ECharacterFaction, damage : float) -> void:
	current_hp = clamp(current_hp, 0.0, current_hp - damage)
	if (current_hp == 0.0):
		if current_map_node:
			current_map_node.on_tower_destroyed(attacker_faction)
