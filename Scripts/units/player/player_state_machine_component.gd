extends UnitStateMachineComponent
class_name PlayerStateMachineComponent

## StateMachine for the player units

# components
@export var movement_component: UnitMovementComponent
@export var look_for_targets_component: UnitLookForTargetsComponent
@export var health_component: UnitHealthComponent
# states
@export var idle_state: PlayerIdleState
@export var move_state: PlayerMoveState
@export var attack_state: PlayerAttackState
@export var retry_state: PlayerRetryState


func setup(map_node: MapNode, slot: Vector2) -> void:
	health_component.init(unit)
	set_new_node_and_path(map_node, null)
	formation_slot = slot
	# by default, start in idle state
	set_state(idle_state)
