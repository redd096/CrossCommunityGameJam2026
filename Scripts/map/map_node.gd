extends Node3D
class_name MapNode

@export var default_faction : OrphanUnit.ECharacterFaction

@export_group("Paths from this node")
## every possible path from this node
@export var paths : Array[MapPath]

@export_group("Tower prefabs")
@export var emptyUnitPrefab : PackedScene 	## OrphaUnit
@export var playerUnitPrefab : PackedScene	## OrphaUnit
@export var enemyUnitPrefab : PackedScene	## OrphaUnit

@export_group("Player spawner")
@export var selected_material: Material ## material used by the tower's roof when this is the selected spawner

@export_group("Arrow Path")
@export var arrowPrefab : PackedScene ## PathPlayerSelector
@export var arrow_distance : float = 2.5 ## distance from this node, in meter along the path

const ROOF_SURFACE: int = 2 ## surface of the tower's mesh with the color of the faction

signal on_conquisted_node(new_faction: OrphanUnit.ECharacterFaction)

var selectedPath : MapPath ## path selected by the player, null when there isn't one or this node is no more of the player
var currentUnit : OrphanUnit ## the tower on this node
var default_roof_material : Material ## roof of the current tower when not selected
var is_selected_spawner : bool ## is this the spawner selected by the player?
var arrows : Array[PathPlayerSelector] ## one for every path
var current_faction: OrphanUnit.ECharacterFaction
## key: path that starts from this node; value: Array[OrphanUnit] on this node/path
## the currentUnit (the tower) is not in this array
var current_units_on_this_node: Dictionary[MapPath, Array]


func _ready() -> void:
	current_faction = default_faction
	_recreate_tower()
	# create disabled arrows
	_create_arrows()
	_update_arrows()


func on_tower_destroyed(destroyer_faction: OrphanUnit.ECharacterFaction) -> void:
	# change faction and emit signal
	current_faction = destroyer_faction
	_recreate_tower()
	on_conquisted_node.emit(destroyer_faction)
	# and disable selected path
	set_selected_path(null)


func _recreate_tower() -> void:
	# destroy previous tower
	if currentUnit:
		currentUnit.queue_free()

	# instantiate tower and initialize
	match (current_faction):
		OrphanUnit.ECharacterFaction.NONE:
			currentUnit = emptyUnitPrefab.instantiate() as OrphanUnit
		OrphanUnit.ECharacterFaction.PLAYER:
			currentUnit = playerUnitPrefab.instantiate() as OrphanUnit
		OrphanUnit.ECharacterFaction.ENEMY:
			currentUnit = enemyUnitPrefab.instantiate() as OrphanUnit
	add_child(currentUnit)
	currentUnit.setup(self)
	# save its roof color, and update it because the new tower doesn't know if this node is selected
	default_roof_material = _get_tower_mesh().get_surface_override_material(ROOF_SURFACE)
	_update_selected_spawner()


#region player selected spawner

## Show if this is the node currently selected as player spawner
func set_selected_spawner(selected: bool) -> void:
	is_selected_spawner = selected
	_update_selected_spawner()


func _update_selected_spawner() -> void:
	# PlayerManager can select this node before its _ready, the tower will be updated when created
	if not currentUnit:
		return

	# change color only if the node is of the player
	var selected: bool = is_selected_spawner and current_faction == OrphanUnit.ECharacterFaction.PLAYER
	_get_tower_mesh().set_surface_override_material(ROOF_SURFACE, selected_material if selected else default_roof_material)


## Every tower inherits from tower_base, so the mesh has always this name
func _get_tower_mesh() -> MeshInstance3D:
	return currentUnit.get_node("MeshInstance3D") as MeshInstance3D

#endregion


#region player selected path

## Set the path that player's units on this node must follow
func set_selected_path(path: MapPath) -> void:
	selectedPath = path
	_update_arrows()


func _create_arrows() -> void:
	# create an arrow for every path
	for path: MapPath in paths:
		var arrow: PathPlayerSelector = arrowPrefab.instantiate() as PathPlayerSelector
		add_child(arrow)
		arrow.setup(self, path, arrow_distance)
		arrows.append(arrow)


func _update_arrows() -> void:
	for arrow: PathPlayerSelector in arrows:
		# show arrows only if the node is of the player
		arrow.set_active(current_faction == OrphanUnit.ECharacterFaction.PLAYER)
		# and highlight selected one
		arrow.set_selected(arrow.map_path == selectedPath)

#endregion


#region units on node

func get_units_on_this_node(path: MapPath) -> Array[OrphanUnit]:
	_init_units_on_this_node_dictionary(path)
	return current_units_on_this_node[path]


func add_unit_to_this_node(unit: OrphanUnit, path: MapPath) -> void:
	_init_units_on_this_node_dictionary(path)
	current_units_on_this_node[path].append(unit)


func remove_unit_from_this_node(unit: OrphanUnit, path: MapPath) -> void:
	_init_units_on_this_node_dictionary(path)
	current_units_on_this_node[path].erase(unit)


func _init_units_on_this_node_dictionary(path: MapPath) -> void:
	if not current_units_on_this_node.has(path):
		# typed var, so the dictionary understand it is a typed Array[OrphanUnit] and not a generic Array
		var units: Array[OrphanUnit] = []
		current_units_on_this_node[path] = units

#endregion
