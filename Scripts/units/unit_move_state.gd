extends State
class_name UnitMoveState

## Movement State of the character, used by its StateMachine

var sm: UnitStateMachineComponent


func _enter_state() -> void:
	sm = state_machine as UnitStateMachineComponent


func _physics_process_state(_delta: float) -> void:
	sm.movement_component.move(sm.unit, sm.unit.current_map_node.get_next_path())
