extends Node
## Test Script:
## - when user select a spawner, just change its color
## - when user spawn a troop, set its path and start position (in the future this should be an Init function)

@export var player_manager: PlayerManager
@export var selected_color: Color = Color.YELLOW

# material applied to the selected spawner mesh
var _selected_material


func _ready() -> void:
	_selected_material = StandardMaterial3D.new()
	_selected_material.albedo_color = selected_color
	# connect events
	player_manager.on_select_spawner.connect(_on_select_spawner)
	player_manager.on_spawn_troop.connect(_on_spawn_troop)
	# set default values
	_on_select_spawner(null, player_manager.current_spawner)


func _on_select_spawner(previous_spawner: Spawner, new_spawner: Spawner) -> void:
	# reset previous material
	if previous_spawner:
		_get_spawner_mesh(previous_spawner).material_override = null
	# set selected material
	if new_spawner:
		_get_spawner_mesh(new_spawner).material_override = _selected_material


func _get_spawner_mesh(spawner: Spawner) -> MeshInstance3D:
	# find first MeshInstance3D child
	return spawner.find_children("*", "MeshInstance3D", false)[0]


func _on_spawn_troop(troop: Node3D) -> void:
	# set troop path
	var path: Path3D = player_manager.current_spawner.path
	troop.path = path
	# and position to the start of the path
	troop.global_position = path.to_global(path.curve.sample_baked(0.0))
