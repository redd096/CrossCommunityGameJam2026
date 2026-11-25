extends State
class_name PlayerAttackState

## Attack State: stay still for a few seconds (attack animation), then destroy the closest target found in area. [br]
## Then continue along the path, or go back to idle if there isn't a path

@export var cooldown: float = 1.0 ## seconds to stay still before attacking the target
@export var first_attack_delay: float = 0.2 # seconds before starting first attack

var sm: PlayerStateMachineComponent
var _target: OrphanUnit
var _attack_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent
	# reset values
	_attack_timer = cooldown - first_attack_delay # start with predetermined delay
	# find closest target
	_target = sm.look_for_targets_component.find_target(OrphanUnit.ECharacterFaction.ENEMY)


func _physics_process_state(delta: float) -> void:
	# no target, or already destroyed by another unit: go back
	if _target == null:
		_back_to_previous_state()
		return

	# when timer is completed, destroy the target and go back
	_attack_timer += delta
	if _attack_timer > cooldown:
		_target.receive_attack(sm.unit.faction, sm.unit.attack_damage)
		_back_to_previous_state()


func _back_to_previous_state() -> void:
	# if we were walking, continue along the path
	if sm.current_map_path != null:
		sm.set_state(sm.move_state)
	# else, back to idle to decide what to do
	else:
		sm.set_state(sm.idle_state)
