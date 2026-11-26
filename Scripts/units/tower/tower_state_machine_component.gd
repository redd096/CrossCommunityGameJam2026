extends UnitStateMachineComponent
class_name TowerStateMachineComponent

## StateMachine for tower units

# components
@export var look_for_targets_component: UnitLookForTargetsComponent
@export var health_component: UnitHealthComponent
# states
@export var idle_state: TowerIdleState
@export var attack_state: TowerAttackState

var enemy_faction: UnitUtilities.ECharacterFaction

func setup(_troop: TroopResource, map_node: MapNode, slot: Vector2) -> void:
	health_component.init(unit)
	
	if (unit.faction == UnitUtilities.ECharacterFaction.ENEMY):
		enemy_faction = UnitUtilities.ECharacterFaction.PLAYER
	else:
		enemy_faction = UnitUtilities.ECharacterFaction.ENEMY

	set_new_node_and_path(map_node, null)
	formation_slot = slot
	# by default, start in idle state
	set_state(idle_state)
