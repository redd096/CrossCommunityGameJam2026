extends UnitStateMachineComponent
class_name EnemyStateMachineComponent

## StateMachine for the enemy units

@export var unit: MovableOrphanUnit
# components
@export var movement_component: UnitMovementComponent
# states
@export var idle_state: EnemyIdleState
@export var defend_state: EnemyDefendState
@export var move_state: EnemyMoveState


func setup(map_node: MapNode, slot: Vector2) -> void:
	current_map_node = map_node
	formation_slot = slot
	# by default, start in idle state
	set_state(idle_state)
