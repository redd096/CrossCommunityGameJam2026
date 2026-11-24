extends OrphanUnit
class_name MovableOrphanUnit

## Base class for a movable unit, used by Player and Enemy

@export var state_machine: UnitStateMachineComponent
@export var spawn_height: float = 1.0 ## fix spawn height, to avoid see unit half in the ground


## Place the unit on its formation slot, then start the state machine [br]
## formation_slot: x = side offset (column), y = distance (row). See MovementUtilities.get_formation_offsets
func setup_movable_unit(map_node: MapNode, formation_slot: Vector2) -> void:
	# call normal setup
	setup(map_node)

	# then move to slot
	global_position += Vector3(formation_slot.x, spawn_height, formation_slot.y)

	# and start statemachine
	state_machine.setup(map_node, formation_slot)



## Called when an enemy destroys this unit
func kill(_destroyer_faction: ECharacterFaction) -> void:
	# stop the states
	state_machine.set_state(null)
	# remove from the node/path list
	state_machine.set_new_node_and_path(null, null)
	queue_free()
