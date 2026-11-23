@abstract
extends StateMachine
class_name UnitStateMachineComponent

# blackboard (vars for states)
var current_map_node: MapNode
var current_struct_path: StructPathNode
var formation_slot: Vector2

@abstract
func setup(map_node: MapNode, slot: Vector2) -> void