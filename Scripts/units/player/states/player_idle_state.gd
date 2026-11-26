extends State
class_name PlayerIdleState

## State when unit is on a node and wait for Player to select a path to start move. [br]
## If the path is already selected, move immediately.
## If there is only one path, don't wait for Player to select it

@export var check_targets_interval: float = 0.1 ## seconds between checks of Player units in attack range

var sm: PlayerStateMachineComponent
var current_node: MapNode

var _targets_timer: float = 0.0


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent
	# stay here, but let the other units pass
	sm.movement_component.wait(sm.unit)
	current_node = sm.current_map_node

	# reset values (set completed timer to do immediatly first check)
	_targets_timer = check_targets_interval

	# arrived on an empty tower: conquer it immediately
	if current_node.current_faction == UnitUtilities.ECharacterFaction.NONE:
		current_node.on_tower_destroyed(sm.unit.faction)


func _process_state(delta: float) -> void:
	# if find targets, attack
	_targets_timer += delta
	if _targets_timer > check_targets_interval:
		_targets_timer = 0.0
		if _check_targets():
			return

	# else, move on the path if selected
	_check_paths()


func _check_targets() -> bool:
	# if find targets, attack
	if sm.look_for_targets_component.are_there_targets(UnitUtilities.ECharacterFaction.ENEMY):
		sm.set_state(sm.attack_state)
		return true
	
	return false


func _check_paths() -> void:
	# if there is a path selected, move along it
	var move_path: MapPath = _get_next_path()
	if move_path != null:
		sm.set_new_node_and_path(current_node, move_path)
		sm.set_state(sm.move_state)

	# else, just wait to recheck what to do
	

func _get_next_path() -> MapPath:
	# if this node isn't of the player (e.g. reconquered by enemies), stay to fight
	# NB this is necessary because the fight check is only every few seconds, not every frame
	if current_node.current_faction != UnitUtilities.ECharacterFaction.PLAYER:
		return null

	# if player selected a path on this node, move to it
	if current_node.selected_path != null:
		return current_node.selected_path
	
	# if there is only one path, move to it
	if current_node.paths.size() == 1:
		return current_node.paths[0]

	# if there is only one path to a node that isn't already of the player, move to it
	var paths_to_conquer: Array[MapPath] = current_node.paths.filter(_is_path_to_conquer)
	if paths_to_conquer.size() == 1:
		return paths_to_conquer[0]

	# else, wait for player to select a path
	return null


func _is_path_to_conquer(path: MapPath) -> bool:
	var target_node: MapNode = path.get_target_node(current_node)
	return target_node.current_faction != UnitUtilities.ECharacterFaction.PLAYER
