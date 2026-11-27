extends Node3D
class_name MapNode

@export var default_faction : UnitUtilities.ECharacterFaction

@export_group("Paths from this node")
## every possible path from this node
@export var paths : Array[MapPath]

@export_group("Tower prefabs")
@export var empty_tower : TroopResource 	## OrphanUnit
@export var player_tower : TroopResource	## OrphanUnit
@export var enemy_tower : TroopResource		## OrphanUnit

@export_group("Player spawner")
@export var flag: Node3D ## shown when this is the selected spawner. This is placed in MapNode prefab

@export_group("Arrow Path")
@export var arrow_prefab : PackedScene ## PathPlayerSelector
@export var arrow_distance : float = 2.5 ## distance from this node, in meter along the path

signal on_conquisted_node(new_faction: UnitUtilities.ECharacterFaction)

var selected_path : MapPath ## path selected by the player, null when there isn't one or this node is no more of the player
var is_selected_spawner : bool ## is this the spawner selected by the player?
var current_faction: UnitUtilities.ECharacterFaction
## key: path that starts from this node; value: Array[OrphanUnit] on this node/path
## the currentUnit (the tower) is not in this array
var current_units_on_this_node: Dictionary[MapPath, Array]

var _current_unit : OrphanUnit ## the tower on this node
var _arrows : Array[PathPlayerSelector] ## one for every path

func _ready() -> void:
	# on instantiate destroy editor tower placeholder
	var placeholders: Array[Node] = find_children("*", "OrphanUnit")
	for p: Node in placeholders: p.queue_free()
	# set faction and tower
	current_faction = default_faction
	_recreate_tower()
	# create disabled arrows
	_create_arrows()
	_update_arrows()


func on_tower_destroyed(destroyer_faction: UnitUtilities.ECharacterFaction) -> void:
	# change faction and emit signal
	current_faction = destroyer_faction
	_recreate_tower()
	on_conquisted_node.emit(destroyer_faction)
	# and disable selected path
	set_selected_path(null)


func _recreate_tower() -> void:
	# destroy previous tower
	if _current_unit:
		_current_unit.queue_free()

	var troop_resource : TroopResource
	# instantiate tower and initialize
	match (current_faction):
		UnitUtilities.ECharacterFaction.NONE:
			troop_resource = empty_tower
		UnitUtilities.ECharacterFaction.PLAYER:
			troop_resource = player_tower
		UnitUtilities.ECharacterFaction.ENEMY:
			troop_resource = enemy_tower

	_current_unit = troop_resource.troop_prefab.instantiate() as OrphanUnit
	add_child(_current_unit)
	_current_unit.setup(troop_resource, self)

	# update the flag, because a new faction can change it
	_update_selected_spawner()


#region player selected spawner

## Show if this is the node currently selected as player spawner
func set_selected_spawner(selected: bool) -> void:
	is_selected_spawner = selected
	_update_selected_spawner()


func _update_selected_spawner() -> void:
	# show the flag only if the node is of the player
	flag.visible = is_selected_spawner and current_faction == UnitUtilities.ECharacterFaction.PLAYER

#endregion


#region player selected path

## Set the path that player's units on this node must follow
func set_selected_path(path: MapPath) -> void:
	selected_path = path
	_update_arrows()


func _create_arrows() -> void:
	# create an arrow for every path
	for path: MapPath in paths:
		var arrow: PathPlayerSelector = arrow_prefab.instantiate() as PathPlayerSelector
		add_child(arrow)
		arrow.setup(self, path, arrow_distance)
		_arrows.append(arrow)


func _update_arrows() -> void:
	for arrow: PathPlayerSelector in _arrows:
		# show arrows only if the node is of the player
		arrow.set_active(current_faction == UnitUtilities.ECharacterFaction.PLAYER)
		# and highlight selected one
		arrow.set_selected(arrow.map_path == selected_path)

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
