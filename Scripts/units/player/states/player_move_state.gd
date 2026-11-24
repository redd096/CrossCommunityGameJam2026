extends State
class_name PlayerMoveState

## Movement State, just move along the path. [br]
## and check if find enemies or reach the end of the path. [br]
## Or stuck by other units and give up

@export var check_targets_interval: float = 0.1 ## seconds between checks of targets in attack range
@export_group("Give Up")
@export var give_up_time: float = 1.0 ## seconds without getting closer to the path end, before giving up
@export var min_progress: float = 0.2 ## how much closer we must get to the path end, to reset give_up_time
@export var give_up_max_distance: float = 3.0 ## give up only this near to the path end, else keep walking (we are just stuck in the crowd)

var sm: PlayerStateMachineComponent
var _targets_timer: float = 0.0
var _give_up_timer: float = 0.0	## if timers reach end, give up to movement
var _best_distance: float = INF ## check if there is a progress to the end of the path, else give up


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent
	# reset values
	_targets_timer = 0.0
	_give_up_timer = 0.0
	_best_distance = INF


func _exit_state() -> void:
	# stop, so this unit becomes an obstacle for the others
	sm.movement_component.stop(sm.unit)


func _physics_process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if sm.look_for_targets_component.are_there_targets(OrphanUnit.ECharacterFaction.ENEMY):
			sm.set_state(sm.attack_state)
			return

	# move along path
	var path: Path3D = sm.current_map_node.get_path_from_struct(sm.current_struct_path)
	var move_forward: bool = sm.current_struct_path.move_forward
	var reached_end: bool = sm.movement_component.move(sm.unit, path, move_forward, sm.formation_slot.x)

	# if reached end of our lane, back to idle with new reached node
	if reached_end:
		var new_node: MapNode = sm.current_map_node.get_map_node_from_struct(sm.current_struct_path)
		sm.set_new_node_and_path(new_node, null)
		sm.set_state(sm.idle_state)
		return

	# increase "give up timer"
	_give_up_timer += delta

	# if we moved near the end path, reset "give up timer"
	var distance: float = sm.movement_component.get_to_end_distance(sm.unit, path, move_forward)
	if distance < _best_distance - min_progress:
		_best_distance = distance
		_give_up_timer = 0.0
	# else, if "give up timer" is completed, stop and wait before retry (we are still on the path)
	elif _give_up_timer > give_up_time and distance < give_up_max_distance:
		sm.set_state(sm.retry_state)
