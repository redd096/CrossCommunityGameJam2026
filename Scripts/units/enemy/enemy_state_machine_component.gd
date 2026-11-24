extends UnitStateMachineComponent
class_name EnemyStateMachineComponent

## StateMachine for the enemy units

# components
@export var movement_component: UnitMovementComponent
@export var look_for_targets_component: UnitLookForTargetsComponent
# states
@export var idle_state: EnemyIdleState
@export var defend_state: EnemyDefendState
@export var move_state: EnemyMoveState
@export var attack_state: EnemyAttackState
@export var retry_state: EnemyRetryState


func setup(map_node: MapNode, slot: Vector2) -> void:
	set_new_node_and_path(map_node, null)
	formation_slot = slot
	# by default, start in idle state
	set_state(idle_state)
