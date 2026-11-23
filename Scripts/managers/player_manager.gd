extends Node
class_name PlayerManager 
## Player manager: manage mana, and what player clicks


@export_group("Mana")
@export var max_mana: int = 100
@export var increment_mana_per_second: float = 10
@export_group("Spawn")
@export var camera: Camera3D
@export var start_selected_spawner: MapNode
@export var spawnable_troops: Array[TroopResource]

const RAY_LENGTH = 1000.0

var current_mana: float
var current_spawner: MapNode

signal on_update_mana(from: int, to: int)
signal on_select_spawner(previous_spawner: MapNode, new_spawner: MapNode)
## Emitted once per spawned unit
signal on_spawn_troop(troop: MovableOrphanUnit)


func _ready() -> void:
	# on start set max mana
	add_mana(max_mana)
	set_spawner(start_selected_spawner)


func _process(delta: float) -> void:
	# increase mana over time
	add_mana(increment_mana_per_second * delta)


func _unhandled_input(event: InputEvent) -> void:
	# check left mouse button click,
	# use _unhandled_input to ignore clicks consumed by UI
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_select_spawner(event.position)


#region public api

## Add value to current mana
func add_mana(increment: float) -> void:
	current_mana = clampf(current_mana + increment, 0, max_mana)
	on_update_mana.emit(current_mana, max_mana)


## Remove value from current mana
func remove_mana(decrement: float) -> void:
	add_mana(-decrement)


## Set selected spawner
func set_spawner(spawner: MapNode) -> void:
	# change spawner
	var previous_spawner: MapNode = current_spawner
	current_spawner = spawner
	on_select_spawner.emit(previous_spawner, current_spawner)

	# register to event to know when this spawner is no more in player's faction
	if previous_spawner:
		previous_spawner.on_conquisted_node.disconnect(_on_conquisted_spawner)
	current_spawner.on_conquisted_node.connect(_on_conquisted_spawner)


## If enough mana, spawn troop on selected spawner
func try_spawn_troop(troop: TroopResource) -> void:
	# if mana is enough, decrease it to spawn troop on selected spawner
	if current_mana >= troop.cost:
		remove_mana(troop.cost)
		var offsets: Array[Vector2] = MovementUtilities.get_formation_offsets(troop.formation_size, troop.formation_spacing, troop.formation_max_columns)
		for slot: Vector2 in offsets:
			_spawn_troop(troop, slot)
	# else, show warning
	else:
		push_warning("TODO - show warning when mana isn't enough")

#endregion


func _spawn_troop(troop: TroopResource, formation_slot: Vector2) -> void:
	# check node is still in player faction
	if current_spawner.current_faction != OrphanUnit.ECharacterFaction.PLAYER:
		push_warning("TODO - Show some feedback that this node is no more Player's node")
		return

	# spawn troop prefab and initialize it
	var spawned_troop: MovableOrphanUnit = troop.troop_prefab.instantiate() as MovableOrphanUnit
	add_child(spawned_troop)
	spawned_troop.setup_movable_unit(current_spawner, formation_slot)
	# and emit signal
	on_spawn_troop.emit(spawned_troop)


func _try_select_spawner(mouse_position: Vector2) -> void:
	# raycast from camera to mouse position
	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position) * RAY_LENGTH
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)

	# check it is a MapNode and it isn't our current selected spawner
	if not hit.is_empty() and hit.collider is MapNode and not hit.collider == current_spawner:
		# be sure it is player faction
		if (hit.collider as MapNode).current_faction == OrphanUnit.ECharacterFaction.PLAYER:
			# then set this as player spawner
			set_spawner(hit.collider)


func _on_conquisted_spawner(new_faction: OrphanUnit.ECharacterFaction) -> void:
	if new_faction != OrphanUnit.ECharacterFaction.PLAYER:
		push_warning("TODO - Show some feedback that this node is no more Player's node")
