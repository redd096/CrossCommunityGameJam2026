extends Node
class_name PlayerMouseManager
## Check what the player is hovering with mouse, and try to select it on click

@export var player_manager: PlayerManager
@export var camera: Camera3D
## The layer that we check to know what player is hovering or clicking
@export_flags_3d_physics var mouse_layer: int = 1 << 5 - 1 # default mouse layer is 5, to get its value in bit we do 1<<(layer-1)

const RAY_LENGTH = 1000.0

## The object currently under the mouse
var current_hover: CollisionObject3D

signal on_start_hover(target: CollisionObject3D)
signal on_end_hover(target: CollisionObject3D)


func _physics_process(_delta: float) -> void:
	# check in _physics_process if the hovered object disappear (e.g. MapNode is no more of the player)
	_set_hover(_find_object_under_mouse())


func _unhandled_input(event: InputEvent) -> void:
	# check left mouse button click,
	# use _unhandled_input to ignore clicks consumed by UI
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_select(current_hover)


#region private hover api

func _set_hover(target: CollisionObject3D) -> void:
	# do nothing if we are still on the same object
	if target == current_hover:
		return

	var previous_hover: CollisionObject3D = current_hover
	current_hover = target

	# end hover on previous object
	if previous_hover:
		on_end_hover.emit(previous_hover)

	# start hover on new object
	if current_hover:
		on_start_hover.emit(current_hover)


## Raycast from camera to mouse position. Return null if there is nothing or the mouse is on UI
func _find_object_under_mouse() -> CollisionObject3D:
	# ignore objects behind UI
	var hovered_control: Control = get_viewport().gui_get_hovered_control()
	if hovered_control and hovered_control.mouse_filter == Control.MOUSE_FILTER_STOP:
		return null

	# raycast
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to, mouse_layer)
	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return null

	return hit.collider as CollisionObject3D

#endregion


#region private click api

func _try_select(target: CollisionObject3D) -> void:
	# check hovered object is still valid (e.g. a conquered tower is destroyed)
	if not is_instance_valid(current_hover):
		return

	# the collider of a MapNode is its tower, 
	# which is an OrphanUnit but not a MovableOrphanUnit
	if target is OrphanUnit and not target is MovableOrphanUnit:
		_try_select_spawner((target as OrphanUnit).current_map_node)
	# or it is an arrow to select a path
	elif target is PathPlayerSelector:
		var arrow: PathPlayerSelector = target as PathPlayerSelector
		arrow.map_node.set_selected_path(arrow.struct_path)


func _try_select_spawner(map_node: MapNode) -> void:
	# be sure it isn't our current selected spawner and it is player faction
	if map_node != player_manager.current_spawner and map_node.current_faction == OrphanUnit.ECharacterFaction.PLAYER:
		# then set this as player spawner
		player_manager.set_spawner(map_node)

#endregion
