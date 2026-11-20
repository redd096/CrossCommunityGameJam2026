extends CharacterBody3D
## Test script: 
## - change color if find target or not


@export var area_overlap: Area3D
@export var area_debug: MeshInstance3D
@export var no_target_color: Color
@export var found_target_color: Color

var mat: StandardMaterial3D


func _ready() -> void:
	# duplicate material to avoid edit material for other objects in scene
	mat = area_debug.get_active_material(0).duplicate()
	area_debug.material_override = mat


func _physics_process(_delta: float) -> void:
	# set color if found target or not
	if FightUtilities.find_target_in_area(area_overlap) != null:
		mat.albedo_color = found_target_color
	else:
		mat.albedo_color = no_target_color
