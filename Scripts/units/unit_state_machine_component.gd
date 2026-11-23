@abstract
extends StateMachine
class_name UnitStateMachineComponent

@export var unit: MovableOrphanUnit

# blackboard (vars for states)
var current_map_node: MapNode
var current_struct_path: StructPathNode
var formation_slot: Vector2

@abstract
func setup(map_node: MapNode, slot: Vector2) -> void


func set_new_node_and_path(map_node: MapNode, path: StructPathNode) -> void:
    # remove from previous
    if current_map_node and current_struct_path:
        current_map_node.remove_unit_from_this_node(unit, current_struct_path)

    current_map_node = map_node
    current_struct_path = path

    # add to new
    if current_map_node and current_struct_path:
        current_map_node.add_unit_to_this_node(unit, current_struct_path)