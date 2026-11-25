extends Node
class_name HoverOutline
## Show an outline on the object hovered by the mouse

@export var player_mouse_manager: PlayerMouseManager
@export var outline_material: Material


func _ready() -> void:
	# connect events
	player_mouse_manager.on_start_hover.connect(_on_start_hover)
	player_mouse_manager.on_end_hover.connect(_on_end_hover)


func _on_start_hover(target: CollisionObject3D) -> void:
	_set_overlay(target, outline_material)


func _on_end_hover(target: CollisionObject3D) -> void:
	_set_overlay(target, null)


## Set material on top of every mesh of the target, without touching its original materials
func _set_overlay(target: CollisionObject3D, material: Material) -> void:
	for mesh: GeometryInstance3D in target.find_children("*", "GeometryInstance3D", true, false):
		mesh.material_overlay = material
