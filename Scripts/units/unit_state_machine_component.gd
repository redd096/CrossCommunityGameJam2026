extends StateMachine
class_name UnitStateMachineComponent

## StateMachine for the character

@export var unit: OrphanUnit
@export var movement_component: UnitMovementComponent
@export var move_state: UnitMoveState

func _ready() -> void:
	# by default, start in move state
	set_state(move_state)