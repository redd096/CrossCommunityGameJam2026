extends Resource
class_name StructPathNode

@export var path : NodePath ## Path3D
@export var mapNode : NodePath  ## MapNode
@export var move_forward: bool = true ## Is this the path forward direction or is reverse?


# extends Path3D
# class_name MapPath

# ## Path that connects two MapNodes

# @export var start_node: MapNode ## node at the start of the path
# @export var end_node: MapNode ## node at the end of the path


# ## The node at the other side of this path
# func get_target_node(from: MapNode) -> MapNode:
#         return end_node if from == start_node else start_node


# ## From this node, do we move in the path direction or in reverse?
# func is_forward(from: MapNode) -> bool:
#         return from == start_node