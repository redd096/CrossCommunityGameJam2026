extends Node
class_name PlayerManager 
## Player manager: manage mana, selected spawner and troops to spawn


@export_group("Mana")
@export var max_mana: int = 100
@export var increment_mana_per_second: float = 10
@export_group("Spawn")
@export var start_selected_spawner: MapNode
@export var spawnable_troops: Array[TroopResource]

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

	# show which spawner is selected
	if previous_spawner:
		previous_spawner.set_selected_spawner(false)
	if current_spawner:
		current_spawner.set_selected_spawner(true)

	# register to event to know when this spawner is no more in player's faction
	if previous_spawner:
		previous_spawner.on_conquisted_node.disconnect(_on_conquisted_spawner)
	if current_spawner:
		current_spawner.on_conquisted_node.connect(_on_conquisted_spawner)


## If there is a selected spawn and enough mana, spawn troops on selected spawner
func try_spawn_troop(troop: TroopResource) -> void:
	# check node is still in player faction
	if not current_spawner or current_spawner.current_faction != OrphanUnit.ECharacterFaction.PLAYER:
		push_warning("TODO - Show some feedback that this node is no more Player's node")
		return

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


#region private spawn api

func _on_conquisted_spawner(new_faction: OrphanUnit.ECharacterFaction) -> void:
	# deselect it, because it's no more Player's node
	if new_faction != OrphanUnit.ECharacterFaction.PLAYER:
		set_spawner(null)


func _spawn_troop(troop: TroopResource, formation_slot: Vector2) -> void:
	# spawn troop prefab and initialize it
	var spawned_troop: MovableOrphanUnit = troop.troop_prefab.instantiate() as MovableOrphanUnit
	add_child(spawned_troop)
	spawned_troop.setup_movable_unit(current_spawner, formation_slot)
	# and emit signal
	on_spawn_troop.emit(spawned_troop)

#endregion
