extends State
class_name TowerIdleState

## Tower checks for possible targets in area

@export var check_targets_interval: float = 0.1 ## seconds between checks of Player units in attack range

var sm: TowerStateMachineComponent
var current_node: MapNode

var _targets_timer: float = 0.0

func _enter_state() -> void:
	sm = state_machine as TowerStateMachineComponent
	current_node = sm.current_map_node

	# reset values (set completed timer to do immediatly first check)
	_targets_timer = check_targets_interval


func _process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if _check_targets():
			return


func _check_targets() -> bool:
	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(sm.enemy_faction):
		sm.set_state(sm.attack_state)
		return true
	
	return false
