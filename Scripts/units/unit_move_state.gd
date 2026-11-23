extends State
class_name UnitMoveState

## Movement State of the character, used by its StateMachine

var sm: UnitStateMachineComponent


func _enter_state() -> void:
	sm = state_machine as UnitStateMachineComponent


func _physics_process_state(_delta: float) -> void:
	# move along path
	var path: Path3D = sm.unit.current_map_node.get_path_from_struct(sm.unit.current_struct_path)
	var move_forward: bool = sm.unit.current_struct_path.move_forward
	sm.movement_component.move(sm.unit, path, move_forward)
