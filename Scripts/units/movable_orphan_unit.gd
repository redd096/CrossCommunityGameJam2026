extends OrphanUnit
class_name MovableOrphanUnit

## Base class for a movable unit, used by Player and Enemy

@export var spawn_height: float = 1.0 ## fix spawn height, to avoid see unit half in the ground


## Set stats, place the unit on its formation slot, then start the state machine [br]
## troop: the resource with the stats of this unit [br]
## formation_slot: x = side offset (column), y = distance (row). See MovementUtilities.get_formation_offsets
func setup_movable_unit(troop_resource: TroopResource, map_node: MapNode, formation_slot: Vector2) -> void:
	# call normal setup
	setup(troop_resource, map_node)

	# then move to slot
	global_position += Vector3(formation_slot.x, spawn_height, formation_slot.y)

	# and start statemachine
	state_machine.setup(troop_resource, map_node, formation_slot)


## Called when an enemy attacks this unit
func receive_attack(_attacker_faction: UnitUtilities.ECharacterFaction, damage : float) -> void:
	# already killed by another attack
	if current_hp <= 0.0:
		return

	current_hp = clamp(current_hp, 0.0, current_hp - damage)

	# dead
	if (current_hp == 0.0):
		is_alive = false
		# stop the states
		state_machine.set_state(null)
		# remove from the node/path list
		state_machine.set_new_node_and_path(null, null)		
		# destroy
		queue_free()
