extends State
class_name EnemyRetryState

## Wait few seconds, then retry to move [br]
## (enter in this state when move give up, because there are other units on the path).
## NB if there are targets, ignore retry timer and attack


@export var check_targets_interval: float = 0.1 ## seconds between checks of targets in attack range
@export var retry_interval: float = 3.0 ## seconds to stay still because gave up, before try moving again

var sm: EnemyStateMachineComponent
var _targets_timer: float = 0.0
var _retry_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	# stay here, but let the other units pass
	sm.movement_component.wait(sm.unit)
	# reset values
	_targets_timer = 0.0
	_retry_timer = 0.0


func _physics_process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if sm.look_for_targets_component.are_there_targets(UnitUtilities.ECharacterFaction.PLAYER):
			sm.set_state(sm.attack_state)
			return

	# if finished retry timer, back to move state
	_retry_timer += delta
	if _retry_timer > retry_interval:
		sm.set_state(sm.move_state)