extends Node
class_name HoverOutline
## Show an outline on the object hovered by the mouse

@export var player_mouse_manager: PlayerMouseManager
@export var outline_color: Color = Color.WHITE
## In mesh local space, so it is multiplied by the scale of the mesh
@export var outline_width: float = 0.02

var _outline_material: StandardMaterial3D


func _ready() -> void:
	# create outline material: a bigger copy of the mesh, where we see only the back faces around the original one
	_outline_material = StandardMaterial3D.new()
	_outline_material.albedo_color = outline_color
	_outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_outline_material.cull_mode = BaseMaterial3D.CULL_FRONT
	_outline_material.grow = true
	_outline_material.grow_amount = outline_width

	# connect events
	player_mouse_manager.on_start_hover.connect(_on_start_hover)
	player_mouse_manager.on_end_hover.connect(_on_end_hover)


func _on_start_hover(target: CollisionObject3D) -> void:
	_set_overlay(target, _outline_material)


func _on_end_hover(target: CollisionObject3D) -> void:
	_set_overlay(target, null)


## Set material on top of every mesh of the target, without touching its original materials
func _set_overlay(target: CollisionObject3D, material: Material) -> void:
	for mesh: GeometryInstance3D in target.find_children("*", "GeometryInstance3D", true, false):
		mesh.material_overlay = material
