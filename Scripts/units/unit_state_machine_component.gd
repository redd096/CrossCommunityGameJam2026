@abstract
extends StateMachine
class_name UnitStateMachineComponent

@export var unit: MovableOrphanUnit

# blackboard (vars for states)
var current_map_node: MapNode
var current_map_path: MapPath
var formation_slot: Vector2

@abstract
func setup(map_node: MapNode, slot: Vector2) -> void


func set_new_node_and_path(map_node: MapNode, path: MapPath) -> void:
    # remove from previous
    if current_map_node and current_map_path:
        current_map_node.remove_unit_from_this_node(unit, current_map_path)

    current_map_node = map_node
    current_map_path = path

    # add to new
    if current_map_node and current_map_path:
        current_map_node.add_unit_to_this_node(unit, current_map_path)


## Is there an ally, inside max_distance, already arrived on this node? (so it isn't walking on a path)
func is_near_unit_arrived_on_node(map_node: MapNode, max_distance: float) -> bool:
    # overlap on the layer of this unit. It can find also enemies or the floor, so check the faction
    for body: Node3D in FightUtilities.find_targets(unit, max_distance, unit.collision_layer):
        var ally: MovableOrphanUnit = body as MovableOrphanUnit
        # be sure it is a unit, of the same faction, not this same object, and on the same map_node (so reached it and it's also alive)
        if ally != null \
            and ally.faction == unit.faction \
            and ally != unit \
            and ally.state_machine.current_map_node == map_node:
            return true

    return false
