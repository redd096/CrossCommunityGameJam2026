extends State
class_name EnemyDefendState

## State when enemy stay still on node and defend it. [br]
## Every few seconds, check if there are still Player units on the path (or they are already dead and this enemy can move) [br]
## or check if they are near to attack them

@export var check_path_interval: float = 1.0 ## seconds between checks of Player units on the paths

var sm: EnemyStateMachineComponent
var _check_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as EnemyStateMachineComponent
	# reset values
	_check_timer = 0.0
	# stay still (nothing calls move_and_slide in this state)
	sm.unit.velocity = Vector3.ZERO


func _physics_process_state(delta: float) -> void:
	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(OrphanUnit.ECharacterFaction.PLAYER):
		sm.set_state(sm.attack_state)
		return

	# every few seconds go back to idle: it comes back here if Player units are still on the paths, else it moves
	_check_timer += delta
	if _check_timer > check_path_interval:
		sm.set_state(sm.idle_state)
