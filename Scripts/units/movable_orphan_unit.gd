extends OrphanUnit
class_name MovableOrphanUnit

## Base class for a movable unit, used by Player and Enemy

@export var state_machine: UnitStateMachineComponent


## Place the unit on its formation slot, then start the state machine [br]
## formation_slot: x = side offset (column), y = distance (row). See MovementUtilities.get_formation_offsets
func setup_movable_unit(map_node: MapNode, formation_slot: Vector2) -> void:
	# call normal setup
	setup(map_node)

	# then move to slot
	global_position += Vector3(formation_slot.x, 0.0, formation_slot.y)

	# and start statemachine
	state_machine.setup(map_node, formation_slot)
