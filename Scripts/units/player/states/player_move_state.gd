extends State
class_name PlayerMoveState

## Movement State, just move along the path. [br]
## and check if find enemies or reach the end of the path

var sm: PlayerStateMachineComponent


func _enter_state() -> void:
	sm = state_machine as PlayerStateMachineComponent


func _physics_process_state(_delta: float) -> void:
	# move along path
	var path: Path3D = sm.current_map_node.get_path_from_struct(sm.current_struct_path)
	var move_forward: bool = sm.current_struct_path.move_forward
	sm.movement_component.move(sm.unit, path, move_forward, sm.formation_slot.x)
