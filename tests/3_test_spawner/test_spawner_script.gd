extends Node
## Test Script:
## - when user select a spawner, just change its color
## - when user spawn a troop, set its path and start position (in the future this should be an Init function)

@export var player_manager: PlayerManager
@export var selected_color: Color = Color.YELLOW
@export var formation_max_columns: int = 3 ## max units side by side in a row
@export var formation_spacing: float = 1.2 ## distance between units

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


#region on select spawner

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

#endregion


#region on spawn troop

func _on_spawn_troop(troop: Node3D, formation_index: int, formation_size: int) -> void:
	# set troop path
	var path: Path3D = player_manager.current_spawner.path
	troop.path = path
	
	# and set troop spawn position
	_spawn_in_grid_test_1(troop, formation_index, formation_size)


func _spawn_at_start_path(troop: Node3D) -> void:
	troop.global_position = MovementUtilities.get_path_start_position(troop.path)


func _spawn_in_grid_test_1(troop: Node3D, formation_index: int, formation_size: int) -> void:
	# find correct column for this "formation" (to spawn unit side by side)
	var columns: int = mini(formation_size, formation_max_columns)
	var column_index: int = formation_index % columns

	# then find correct row (if there are more rows because "formation" exceed formation_max_columns)
	@warning_ignore("integer_division")
	var row_index: int = formation_index / columns

	# calculate to have column 0 at the left instead of the center
	# e.g. we have 10 columns and we want to stay in column 5, we must be in the center and not to the right
	var remaining_units: int = formation_size - row_index * columns
	var columns_in_this_row: int = mini(columns, remaining_units)
	var half_size: float = (columns_in_this_row - 1) / 2.0 * formation_spacing	# center row with less units then formation_max_columns
	# var half_size: float = (columns - 1) / 2.0 * formation_spacing
	var offset_to_the_right: float = column_index * formation_spacing
	var side_offset: float = offset_to_the_right - half_size
	troop.side_offset = side_offset

	# default order: the row 0 is at the start of the path, and the last row is forward along the path
	var progress: float = row_index * formation_spacing

	# # inverse order: the last row is at the start of the path, and row 0 is forward along the path
	# @warning_ignore("integer_division")
	# var last_row_index: int = (formation_size - 1) / columns
	# var progress: float = (last_row_index - row_index) * formation_spacing

	troop.global_position = MovementUtilities.get_path_global_position(troop.path, progress, side_offset)


func _spawn_in_grid_test_2(troop: Node3D, formation_index: int, formation_size: int) -> void:
	# find this unit slot in the formation 
	# x = side offset (column), y = distance (row)
	var offsets: Array[Vector2] = _get_formation_offsets(formation_size, formation_spacing, formation_max_columns)
	var slot: Vector2 = offsets[formation_index]
	troop.side_offset = slot.x

	# default order: the row 0 is at the start of the path, and the last row is forward along the path
	var progress: float = slot.y

	# # inverse order: the last row is at the start of the path, and row 0 is forward along the path
	# var longest: float = 0.0
	# for offset: Vector2 in offsets:
	# 	longest = maxf(longest, offset.y)
	# var progress: float = longest - slot.y

	# and position at its "slot" near the start of the path
	troop.global_position = MovementUtilities.get_path_global_position(troop.path, progress, slot.x)


## Return the slot offsets of a formation made of columns and rows [br]
## x = side offset (column, where negative is left and positive is right), y = distance (row) [br]
## unit_count: the number of units in this formation [br]
## spacing: distance between two units, both side by side and between rows [br]
## max_columns: max units side by side in a row
static func _get_formation_offsets(unit_count: int, spacing: float, max_columns: int) -> Array[Vector2]:
	var offsets: Array[Vector2] = []
	var row: int = 0

	while offsets.size() < unit_count:
		# full rows have max_columns units, the last one only the remaining units
		var remaining_units: int = unit_count - offsets.size()
		var columns_in_this_row: int = mini(max_columns, remaining_units)

		# calculate to have column 0 at the left instead of the center
		# e.g. we have 10 columns and we want to stay in column 5, we must be in the center and not to the right
		var half_size: float = (columns_in_this_row - 1) / 2.0 * spacing
		for column_index: int in columns_in_this_row:
			var offset_to_the_right: float = column_index * spacing
			var side_offset: float = offset_to_the_right - half_size
			offsets.append(Vector2(side_offset, row * spacing))
		
		# move to next row
		row += 1

	return offsets

#endregion