extends StaticBody3D
class_name PathPlayerSelector

## Arrow on a MapNode, that player can click to select one of its paths

@export var mesh: MeshInstance3D
@export var collision_shape: CollisionShape3D
@export var selected_material: Material ## material used when this is the selected path

var map_node: MapNode
var map_path: MapPath


## Save values and place the arrow on the path, looking at its direction [br]
## distance: how far from the map node, in meter along the path
func setup(_map_node: MapNode, _map_path: MapPath, distance: float) -> void:
	map_node = _map_node
	map_path = _map_path

	# calculate node and arrow position on the path
	# NB when the path is in reverse, this node is at the end of the path
	var move_forward: bool = map_path.is_forward(map_node)
	var length: float = map_path.curve.get_baked_length()
	var node_progress: float = 0.0 if move_forward else length
	var arrow_progress: float = distance if move_forward else length - distance

	# calculate node and arrow position in global space
	var node_position: Vector3 = MovementUtilities.get_path_global_position(map_path, node_progress)
	var arrow_position: Vector3 = MovementUtilities.get_path_global_position(map_path, arrow_progress)

	# place the arrow, and look at direction
	global_position = arrow_position
	var direction: Vector3 = arrow_position - node_position
	look_at(arrow_position + direction)


## Show or hide the arrow. And disable also collision, so mouse can't click it
func set_active(active: bool) -> void:
	visible = active
	collision_shape.disabled = not active


## Show if this is the path currently selected on the node
func set_selected(selected: bool) -> void:
	mesh.material_override = selected_material if selected else null
