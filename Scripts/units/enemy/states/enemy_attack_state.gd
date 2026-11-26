extends State
class_name EnemyAttackState

## Attack State: stay still for a few seconds (attack animation), then destroy the closest target found in area. [br]
## Then continue along the path, or go back to idle if there isn't a path

@export var attack_delay: float = 0.2 ## seconds to stay still before attacking the target

var sm: EnemyStateMachineComponent
var _target: OrphanUnit
var _attack_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	# keep this position, nobody can move this unit during the attack
	sm.movement_component.stop(sm.unit)
	# reset values
	_attack_timer = 0.0
	# find closest target
	_target = sm.look_for_targets_component.find_target(UnitUtilities.ECharacterFaction.PLAYER)


func _physics_process_state(delta: float) -> void:
	# no target, already destroyed by another unit, or out of range: go back
	if _target == null or not sm.look_for_targets_component.is_in_area(_target):
		_back_to_previous_state()
		return

	# when timer is completed, attack the target and go back
	_attack_timer += delta
	if _attack_timer > attack_delay:
		_target.receive_attack(sm.unit.faction, sm.unit.attack_damage)
		_back_to_previous_state()


func _back_to_previous_state() -> void:
	# if we were walking, continue along the path
	if sm.current_map_path != null:
		sm.set_state(sm.move_state)
	# else, back to idle to decide what to do
	else:
		sm.set_state(sm.idle_state)
