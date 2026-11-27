extends CharacterBody3D
class_name OrphanUnit

## Base script for a Unit
@export var state_machine: UnitStateMachineComponent

var is_alive: bool
var faction: UnitUtilities.ECharacterFaction
var current_hp : float
var attack_damage : float
var current_map_node: MapNode


## Set stats, place the unit on its formation slot, then start the state machine [br]
## troop_resource: the resource with the stats of this unit [br]
## formation_slot: x = side offset (column), y = distance (row). See MovementUtilities.get_formation_offsets
func setup(troop_resource: TroopResource, map_node: MapNode, formation_slot: Vector2) -> void:
	is_alive = true

	# set values
	faction = troop_resource.faction
	current_hp = troop_resource.health
	attack_damage = troop_resource.attack_damage
	current_map_node = map_node

	# set position
	global_position = current_map_node.global_position
	global_position += Vector3(formation_slot.x, 0, formation_slot.y)

	# start statemachine
	if (state_machine):
		state_machine.setup(troop_resource, map_node, formation_slot)

## Called when an enemy attacks this unit. Extended from MovableOrphanUnit [br]
func receive_attack(attacker_faction: UnitUtilities.ECharacterFaction, damage : float, _from_position: Vector3) -> void:
	# already destroyed
	if current_hp <= 0.0:
		return

	current_hp = clamp(current_hp, 0.0, current_hp - damage)

	# dead
	if (current_hp == 0.0):
		is_alive = false
		if current_map_node:
			current_map_node.on_tower_destroyed(attacker_faction)
