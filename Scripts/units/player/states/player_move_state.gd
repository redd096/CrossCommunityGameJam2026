extends State
class_name PlayerMoveState

## Movement State, just move along the path. [br]
## and check if find enemies or reach the end of the path

@export var give_up_time: float = 1.0 ## seconds without getting closer to the path end, before giving up
@export var min_progress: float = 0.2 ## how much closer we must get to the path end, to reset give_up_time

const DISTANCE_REACH_NODE: float = 0.2

var sm: PlayerStateMachineComponent
var _give_up_timer: float = 0.0	## if timers reach end, give up to movement
var _best_distance: float = INF ## check if there is a progress to the end of the path, else give up


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent
	# reset values
	_give_up_timer = 0.0
	_best_distance = INF


func _physics_process_state(delta: float) -> void:
	# move along path
	var path: Path3D = sm.current_map_node.get_path_from_struct(sm.current_struct_path)
	var move_forward: bool = sm.current_struct_path.move_forward
	sm.movement_component.move(sm.unit, path, move_forward, sm.formation_slot.x)

	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(OrphanUnit.ECharacterFaction.ENEMY):
		sm.set_state(sm.attack_state)
		return
	
	# check if reach end of the path or give up, to go back to idle

	# increase "give up timer"
	_give_up_timer += delta

	# if we moved near the end path, reset "give up timer"
	var distance: float = sm.movement_component.get_to_end_distance(sm.unit, path, move_forward)
	if distance < _best_distance - min_progress:
		_best_distance = distance
		_give_up_timer = 0.0
	# if reached node, back to idle with new reached node
	elif distance < DISTANCE_REACH_NODE:
		var new_node: MapNode = sm.current_map_node.get_map_node_from_struct(sm.current_struct_path)
		sm.set_new_node_and_path(new_node, null)
		sm.set_state(sm.idle_state)
	# else, if "give up timer" is completed, back to idle with new reached node
	elif _give_up_timer > give_up_time:
		var new_node: MapNode = sm.current_map_node.get_map_node_from_struct(sm.current_struct_path)
		sm.set_new_node_and_path(new_node, null)
		sm.set_state(sm.idle_state)
