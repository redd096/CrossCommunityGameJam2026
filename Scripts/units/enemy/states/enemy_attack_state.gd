extends State
class_name EnemyAttackState

## Attack State: stay still for a few seconds (attack animation), then destroy the closest target found in area. [br]
## Then continue along the path, or go back to idle if there isn't a path

@export var attack_time: float = 2.0 ## seconds to stay still before destroying the target

var sm: EnemyStateMachineComponent
var _target: OrphanUnit
var _attack_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	# reset values
	_attack_timer = 0.0
	# find closest target
	_target = sm.look_for_targets_component.find_target(OrphanUnit.ECharacterFaction.PLAYER)


func _physics_process_state(delta: float) -> void:
	# no target, or already destroyed by another unit: go back
	if _target == null:
		_back_to_previous_state()
		return

	# else, when timer is completed, destroy the target and go back
	_attack_timer += delta
	if _attack_timer > attack_time:
		_target.kill(sm.unit.faction)
		_back_to_previous_state()


func _back_to_previous_state() -> void:
	# if we were walking, continue along the path
	if sm.current_struct_path != null:
		sm.set_state(sm.move_state)
	# else, back to idle to decide what to do
	else:
		sm.set_state(sm.idle_state)
