extends UnitStateMachineComponent
class_name EnemyStateMachineComponent

## StateMachine for the enemy units

# components
@export var movement_component: UnitMovementComponent
@export var look_for_targets_component: UnitLookForTargetsComponent
@export var health_component: UnitHealthComponent
# states
@export var idle_state: EnemyIdleState
@export var defend_state: EnemyDefendState
@export var move_state: EnemyMoveState
@export var attack_state: EnemyAttackState
@export var retry_state: EnemyRetryState


func setup(troop: TroopResource, map_node: MapNode, slot: Vector2) -> void:
	# set components stats
	movement_component.set_speed(troop.move_speed)
	look_for_targets_component.set_radius(troop.attack_range)
	health_component.init(unit)
	attack_state.attack_delay = troop.attack_delay

	# set map_node and slot
	set_new_node_and_path(map_node, null)
	formation_slot = slot
	
	# by default, start in idle state
	set_state(idle_state)
