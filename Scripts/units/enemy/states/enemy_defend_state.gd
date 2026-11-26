extends State
class_name EnemyDefendState

## State when enemy stay still on node and defend it. [br]
## Every few seconds, check if there are still Player units on the path (or they are already dead and this enemy can move) [br]
## or check if they are near to attack them

@export var check_targets_interval: float = 0.1 ## seconds between checks of Player units in attack range
@export var check_path_interval: float = 1.0 ## seconds between checks of Player units on the paths

var sm: EnemyStateMachineComponent
var _targets_timer: float = 0.0
var _path_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	# stay here, but let the other units pass
	sm.movement_component.wait(sm.unit)
	# reset values
	_targets_timer = 0.0
	_path_timer = 0.0


func _physics_process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if sm.look_for_targets_component.are_there_targets(UnitUtilities.ECharacterFaction.PLAYER):
			sm.set_state(sm.attack_state)
			return

	# every few seconds go back to idle: it comes back here if Player units are still on the paths, else it moves
	_path_timer += delta
	if _path_timer > check_path_interval:
		sm.set_state(sm.idle_state)
